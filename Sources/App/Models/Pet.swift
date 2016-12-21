//
//  Pet.swift
//  Veterinary
//
//  Created by Clement Yerochewski on 12/20/16.
//
//

import Vapor
import Fluent

final class Pet: Model {
    
    var exists: Bool = false
    var id: Node?
    var owner_id: Node?
    var name: String
    var type: String

    init(name: String, type: String) {
        self.name = name
        self.type = type
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        type = try node.extract("type")
        owner_id = try node.extract("owner_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "type": type,
            "owner_id": owner_id
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("pets") { pets in
            pets.id()
            pets.string("name")
            pets.string("type")
            pets.parent(Owner.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("pets")
    }
}

extension Sequence where Iterator.Element == Pet {
    func makeJSON() throws -> JSON  {
        let result = try self.map { try $0.makeNode() }
        return try JSON(result.makeNode())
    }
}

extension Pet {
    func owner() throws -> Parent<Owner> {
        return try parent(owner_id)
    }
    
    func toys() throws -> Siblings<Toy> {
        return try siblings()
    }

}


