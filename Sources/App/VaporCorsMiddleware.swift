//
//  VaporCorsMiddleware.swift
//
//
//  Created by Иван Копиев on 20.04.2024.
//

import Foundation
import Vapor


// Создаем структуру для Middleware
struct CORSMiddleware: Middleware {

    // Промежуточное ПО для обработки запроса
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Вызываем следующее промежуточное ПО и получаем ответ
        let responseFuture = next.respond(to: request)

        // Обрабатываем заголовки ответа с CORS
        return responseFuture.map { response in
            // Добавляем заголовки CORS в ответ
            response.headers.add(name: "Access-Control-Allow-Origin", value: "*")
            response.headers.add(name: "Access-Control-Allow-Methods", value: "GET, POST, OPTIONS")
            response.headers.add(name: "Access-Control-Allow-Headers", value: "Content-Type, Authorization")

            return response
        }
    }
}

// Расширяем Application для удобного добавления Middleware
extension Application {
    func addCORSMiddleware() {
        // Добавляем созданный Middleware в цепочку Middleware приложения
        middleware.use(CORSMiddleware())
    }
}
