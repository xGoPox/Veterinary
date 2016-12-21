import Vapor
import VaporPostgreSQL
import Fluent

let drop = Droplet()

try drop.addProvider(VaporPostgreSQL.Provider.self)

drop.preparations = [Owner.self, Pet.self, Toy.self, Pivot<Toy, Pet>.self]

drop.get("owners", "all") { request in
    return JSON(["owners": try Owner.query().all().makeJSON()])
}

drop.get("owner", Int.self, "pets") { request , owner_id in
    guard let owner = try Owner.query().filter("id", Node(owner_id)).first() else {
        throw Abort.badRequest
    }
    
    let pets = try owner.pets().all()
    return try pets.makeJSON()
}


drop.post("owners") { request in
    guard let name = request.data["name"]?.string else {
        throw Abort.badRequest
    }
    var owner = Owner(name: name)
    try owner.save()
    return owner
}

drop.post("pets", Int.self) { request, owner_id in
    
    guard let name = request.data["name"]?.string ,
        let type = request.data["type"]?.string,
        let owner = try Owner.query().filter("id", Node(owner_id)).first()  else {
            throw Abort.badRequest
    }
    
    var pet = Pet(name: name, type: type)
    pet.owner_id = owner.id
    try pet.save()
    
    return pet
}

drop.post("toys", String.self) { request , name in
    
    var toy = Toy(name: name)
    try toy.save()
    
    var pets = try Pet.query().all()
    
    for pet in pets {
        var pivot = Pivot<Toy, Pet>(toy, pet)
        try pivot.save()
    }
    
    return JSON(["toy": try toy.makeJSON(), "pets" : try toy.pets().all().makeJSON()])
}



drop.run()
