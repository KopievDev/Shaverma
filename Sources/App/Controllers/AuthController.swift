//
//  AuthController.swift
//
//
//  Created by Иван Копиев on 31.03.2024.
//

import Foundation
import Vapor
import VaporToOpenAPI

struct AuthController: RouteCollection {

    let app: Application

    func boot(routes: RoutesBuilder) throws {
        /// Token check
        let tokenProtected = app.grouped(UserToken.authenticator()).grouped("api", "v1")
        /// Basic auth
        let passwordProtected = app.grouped(User.authenticator()).grouped("api", "v1")
        /// Without checking
        let api = routes.grouped("api","v1")

        api.post("register", use: register)
            .openAPI(
                tags: .init(name: "Auth"),
                summary: "Регистрация",
                description: "Регистрация нового пользователя",
                body: .type(User.Create.self),
                contentType: .application(.json),
                response: .type(AuthResponse.self),
                responseContentType: .application(.json),
                responseHeaders: .all(of: .type(Headers.AccessToken.self)),
                responseDescription: "Success response"
            ).response(statusCode: 400, description: "Invalid username/password supplied")

        passwordProtected.get("login", use: auth)
            .openAPI(
                tags: .init(name: "Auth"),
                summary: "Авторизация",
                description: "Авторизация пользователя по почте и паролю",
                headers: .all(of: .type(Headers.Authorization.self)),
                contentType: .application(.json),
                response: .type(AuthResponse.self),
                responseContentType: .application(.json),
                responseHeaders: .all(of: .type(Headers.AccessToken.self)),
                responseDescription: "Success response"
            ).response(statusCode: 400, description: "Invalid username/password supplied")

        tokenProtected.get("logout", use: logout)
            .openAPI(
                tags: .init(name: "Auth"),
                summary: "Выход",
                description: "Выход из аккаунта",
                headers: .all(of: .type(Headers.AccessToken.self)),
                contentType: .application(.json),
                response: .type(MessageResponse.self),
                responseContentType: .application(.json),
                responseDescription: "Success response"
            )

        tokenProtected.get("me", use: me)
            .openAPI(
                tags: .init(name: "User"),
                summary: "Профиль",
                description: "Данные профиля",
                headers: .all(of: .type(Headers.AccessToken.self)),
                contentType: .application(.json),
                response: .type(UserResponse.self),
                responseContentType: .application(.json),
                responseHeaders: .all(of: .type(Headers.AccessToken.self)),
                responseDescription: "Success response"
            )
    }

    func auth(req: Request) async throws -> AuthResponse {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return AuthResponse(token: token.value)
    }

    func register(req: Request) async throws -> AuthResponse {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        let user = try User(
            id: .generateRandom(),
            email: create.email,
            password: Bcrypt.hash(create.password),
            name: create.name,
            familyName: create.familyName,
            phone: create.phone
        )
        let token = try user.generateToken()
        try await user.save(on: req.db)
        try await token.save(on: req.db)
        return .init(token: token.value)
    }

    func logout(req: Request) async throws -> MessageResponse {
        guard let token = req.auth.get(UserToken.self)?.value else {
            throw Abort(.nonAuthoritativeInformation)
        }
        let tokens = try await UserToken.query(on: req.db).all()
        guard let logoutToken = tokens.first(where: { $0.value == token }) else {
            throw Abort(.nonAuthoritativeInformation)
        }
        try await logoutToken.delete(on: req.db)
        return MessageResponse(message: "Ok")
    }
    
    func me(req: Request) async throws -> UserResponse {
        let user = try req.auth.require(User.self)
        return UserResponse(name: user.name, familyName: user.familyName, email: user.email, phone: user.phone)
    }
}
