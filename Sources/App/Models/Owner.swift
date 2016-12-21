//
//  Owner.swift
//  Veterinary
//
//  Created by Clement Yerochewski on 12/20/16.
//
//

import Vapor
import Fluent


final class Owner: Model {
    var exists: Bool = false
    var id: Node?
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("owners") { owners in
            owners.id()
            owners.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("owners")
    }
}

extension Owner {
    func pets() throws -> Children<Pet> {
        return children()
    }
    
    public func makeJSON() throws -> JSON {
        return JSON([
            "owner": try self.makeNode(),
            "pets": try Node(node: self.pets().all().makeJSON())
            ])
    }
}

extension Sequence where Iterator.Element == Owner {
    func makeJSON() throws -> JSON  {
        let result = try self.map { try $0.makeJSON() }
        return try JSON(result.makeNode())
    }
}

