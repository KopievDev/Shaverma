//
//  Setting.swift
//
//
//  Created by Иван Копиев on 21.05.2024.
//

import Vapor
import Fluent
import Foundation

final class Setting: Model, Content {
    static var schema: String = "settings"

    @ID(key: .id)
    var id: UUID?
    @Field(key: "title")
    var title: String
    @Field(key: "type")
    var type: String
    @Field(key: "paywall")
    var paywall: String
    @Field(key: "black_paywall")
    var blackPaywall: String
    @Field(key: "is_need_rate")
    var isNeedRate: Bool
    @Field(key: "review_version")
    var reviewVersion: String?
    @Field(key: "appImage")
    var appImage: String?

    required init() { }

    init(
        id: UUID? = nil,
        title: String,
        appImage: String? = nil,
        type: String,
        paywall: String,
        blackPaywall: String,
        isNeedRate: Bool,
        reviewVersion: String? = nil
    ) {
        self.id = id
        self.title = title
        self.appImage = appImage
        self.type = type
        self.paywall = paywall
        self.blackPaywall = blackPaywall
        self.isNeedRate = isNeedRate
        self.reviewVersion = reviewVersion
    }
}

extension Setting {
    func update(with setting: SettingRequest) {
        paywall = setting.paywall
        blackPaywall = setting.black_paywall
        isNeedRate = setting.is_need_rate
        reviewVersion = setting.review_version
    }
}

extension Setting {
    struct Migration: AsyncMigration {
        var name: String { "CreateSettings" }

        func prepare(on database: Database) async throws {
            try await database.schema(Setting.schema)
                .id()
                .field("title", .string, .required)
                .field("type", .string, .required)
                .field("paywall", .string, .required)
                .field("black_paywall", .string, .required)
                .field("review_version", .string)
                .field("appImage", .string)
                .field("is_need_rate", .bool)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(Setting.schema).delete()
        }
    }
}

import Vapor
import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

@OpenAPIDescriptable()
/// Апп
struct AppResponse: Content, WithExample {
    /// Image
    let appImage: String
    /// Title
    let title: String
    /// Type
    let type: String

    static var example: AppResponse = .init(appImage: "some url", title: "App name", type: "type")

}
extension AppResponse {
    init(setting: Setting) {
        self.appImage = setting.appImage ?? "https://mustdev.ru/adminka/icons8-apple-app-store.svg"
        self.type = setting.type
        self.title = setting.title
    }

    func make() -> Setting {
        .init(
            id: .generateRandom(),
            title: title,
            appImage: appImage,
            type: type,
            paywall: "", 
            blackPaywall: "",
            isNeedRate: true,
            reviewVersion: nil
        )
    }
}

@OpenAPIDescriptable()
/// Апп
struct SettingResponse: Content, WithExample {
    /// Image
    let appImage: String
    /// Title
    let title: String
    /// Type
    let type: String
    /// paywall
    let paywall: String
    /// black_paywall
    let black_paywall: String
    /// review_version
    let review_version: String?
    /// is_need_rate
    let is_need_rate: Bool

    static var example: SettingResponse = .init(
        appImage: "some url",
        title: "App name",
        type: "type",
        paywall: "some",
        black_paywall: "some",
        review_version: "1.2.3",
        is_need_rate: false
    )
}

extension SettingResponse {
    init(setting: Setting) {
        self.appImage = setting.appImage ?? "https://mustdev.ru/adminka/icons8-apple-app-store.svg"
        self.type = setting.type
        self.title = setting.title
        self.paywall = setting.paywall
        self.black_paywall = setting.blackPaywall
        self.review_version = setting.reviewVersion
        self.is_need_rate = setting.isNeedRate
    }

    func make() -> Setting {
        .init(
            id: .generateRandom(),
            title: title,
            appImage: appImage,
            type: type,
            paywall: paywall,
            blackPaywall: black_paywall,
            isNeedRate: is_need_rate,
            reviewVersion: review_version
        )
    }
}

@OpenAPIDescriptable()
/// Апп
struct SettingRequest: Content, WithExample {
    /// Type
    let type: String
    /// paywall
    let paywall: String
    /// black_paywall
    let black_paywall: String
    /// review_version
    let review_version: String?
    /// is_need_rate
    let is_need_rate: Bool

    static var example: SettingRequest = .init(
        type: "type",
        paywall: "some",
        black_paywall: "some",
        review_version: "1.2.3",
        is_need_rate: false
    )
}

