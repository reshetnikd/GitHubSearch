//
//  Repository.swift
//  GitHubSearch
//
//  Created by Dmitry Reshetnik on 04.12.2020.
//

import Foundation

enum GitHubAPI {
    static let BaseURL = URL(string: "https://api.github.com")!
}

struct Repository {
    var name: String?
    var description: String?
    var url: String?
}
