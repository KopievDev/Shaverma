//
//  AppAdminController.swift
//
//
//  Created by Иван Копиев on 21.05.2024.
//

import Vapor
import Fluent
import Foundation
import VaporToOpenAPI

struct AppAdminController: RouteCollection {

    let tokenProtected: RoutesBuilder

    func boot(routes: RoutesBuilder) throws {
        let admin = tokenProtected.grouped("settings")

        admin.get(use: appList)
            .openAPI(
                tags: .init(name: "App Console"),
                summary: "Админка приложения",
                description: "Список приложений",
                headers: .all(of: .type(Headers.AccessToken.self)),
                contentType: .application(.json),
                response: .type([SettingResponse].self),
                responseContentType: .application(.json),
                responseDescription: "Success response"
            )

        admin.get(":type", use: getAppWithType)
            .openAPI(
                tags: .init(name: "App Console"),
                summary: "Админка приложения",
                description: "Приложениe по типу",
                headers: .all(of: .type(Headers.AccessToken.self)),
                contentType: .application(.json),
                response: .type(SettingResponse.self),
                responseContentType: .application(.json),
                responseDescription: "Success response"
            )

        admin.post(use: createApp)
            .openAPI(
                tags: .init(name: "App Console"),
                summary: "Добавить приложение",
                description: "Добавление новое приложение",
                headers: .all(of: .type(Headers.AccessToken.self)),
                body: .all(of: .type(AppResponse.self)),
                contentType: .application(.json),
                response: .type(AppResponse.self),
                responseContentType: .application(.json),
                responseDescription: "Success response"
            )

        admin.put("update", use: updateAppData)
            .openAPI(
                tags: .init(name: "App Console"),
                summary: "Обновить приложение",
                description: "Обновление данных в приложении",
                headers: .all(of: .type(Headers.AccessToken.self)),
                body: .all(of: .type(SettingRequest.self)),
                contentType: .application(.json),
                response: .type(SettingResponse.self),
                responseContentType: .application(.json),
                responseDescription: "Success response"
            )
    }

    func appList(req: Request) async throws -> [SettingResponse] {
        let user = try req.auth.require(User.self)
//        guard user.role == .admin else {
//            throw Abort(.forbidden)
//        }
        
        return try await Setting.query(on: req.db).all().compactMap(SettingResponse.init)
    }

    func createApp(req: Request) async throws -> AppResponse {
        let user = try req.auth.require(User.self)
        let request = try req.content.decode(AppResponse.self)
//        guard user.role == .admin else {
//            throw Abort(.forbidden)
//        }
        let setting = request.make()
        try await setting.save(on: req.db)
        return AppResponse(setting: setting)
    }

    func getAppWithType(req: Request) async throws -> SettingResponse {
        let user = try req.auth.require(User.self)
//        guard user.role == .admin else {
//            throw Abort(.forbidden)
//        }
        guard let type = req.parameters.get("type") else {
            throw Abort(.custom(code: 404, reasonPhrase: "Не указан тип"))
        }
        let setting = try await Setting
            .query(on: req.db)
            .filter(\.$type == type)
            .first()

        guard let setting else {
            throw Abort(.custom(code: 404, reasonPhrase: "Нет такого типа"))
        }
        return SettingResponse(setting: setting)
    }

    func updateAppData(req: Request) async throws -> SettingResponse {
        let user = try req.auth.require(User.self)
        let request = try req.content.decode(SettingRequest.self)

//        guard user.role == .admin else {
//            throw Abort(.forbidden)
//        }

        let setting = try await Setting
            .query(on: req.db)
            .filter(\.$type == request.type)
            .first()
        guard let setting else {
            throw Abort(.custom(code: 404, reasonPhrase: "Нет такого типа"))
        }
        setting.update(with: request)
        try await setting.save(on: req.db)
        return SettingResponse(setting: setting)
    }
}
