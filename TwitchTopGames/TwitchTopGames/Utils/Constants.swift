    //
//  Constants.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 03/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import UIKit
    
    struct K {
        struct ViewControllers {
            struct TopGames {
                static var title = "Top Games 🏆"
                
                struct Cells {
                    static var topGameCellIdentifier = "gameCell"
                    static var topClipCellIdentifier = "clipCell"
                }
            }
        }
        struct Alerts {
            struct Title {
                static var error = "Ops"
            }
            struct Message {
                static var error = "Aconteceu um erro, tente novamente mais tarde."
                static var emptyTableTitle = "Não encontrei nada para exibir aqui 🥺"
                static var emptyTableMessage = "Você pode \"puxar para baixo\" para recarregar a lista."
            }
        }
        struct Buttons {
            static var cancel = "Cancelar"
            static var alertOkButton = "Ok"
        }
        struct API {
            struct Base {
                static var url = "https://api.twitch.tv"
                static var version = "kraken"
            }
            struct Headers {
                struct Field {
                    static var accept = "Accept"
                    static var clientKey = "Client-ID"
                    static var contentType = "Content-Type"
                }
                struct Value {
                    static var accept = "application/vnd.twitchtv.v5+json"
                    static var clientKey = "46z8t2f6t6qkaxxdkbvpa1ivbf9us4"
                    static var contentType = "application/json"
                }
            }
            
            struct ErrorMessage {
                static var requestFailed = "Erro de requisição"
                static var invalidData = "Retorno inválido"
                static var responseUnsuccessful = "Serviço está falhando e não trazendo erro"
                static var jsonParsingFailure = "Erro ao converter objetos para envio"
                static var jsonConversionFailure = "Objetos mapeados e retorno do serviço estão diferentes"
                static var decryptFailed = "Não foi possível descriptar os dados"
                static var encryptFailed = "Não foi possível encriptar os dados"
                static var unkownError = "Número de erro do serviço não mapeado"
            }
            
            enum HTTPMethod: String {
                case GET = "get"
                case POST = "post"
                case DELETE = "delete"
                case PUT = "put"
            }
        }        
    }
