import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import NIOTLS

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(
        FileMiddleware(
            publicDirectory: app.directory.publicDirectory,
            defaultFile: "index.html"
        )
    )
    app.addCORSMiddleware()
    app.http.server.configuration.hostname = "shavastreet.ru"
    app.http.server.configuration.tlsConfiguration = .makeServerConfiguration(
        // Путь к вашему fullchain.pem
        certificateChain: [.certificate(try .init(file: "/etc/ssl/shavastreet/fullchain.pem", format: .pem))],
        // Путь к вашему privkey.pem
        privateKey: .file("/etc/ssl/shavastreet/private.pem")
    )
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(User.Migration())
    app.migrations.add(User.AddRoleMigration())
    app.migrations.add(UserToken.Migration())
    app.migrations.add(Categoties.Migration())
    app.migrations.add(Products.Migration())
    app.migrations.add(Products.AddImageMigration())
    app.migrations.add(Addresses.Migration())
    app.migrations.add(TelegramData.Migration())
    app.migrations.add(Promos.Migration())
    app.migrations.add(Cart.Migration())
    app.migrations.add(CartItem.Migration())
    app.migrations.add(Order.Migration())
    app.migrations.add(OrderSequence.Migration())
    app.migrations.add(OrderItem.Migration())
    app.migrations.add(Setting.Migration())
    try await app.autoMigrate()

    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    try routes(app)
}
