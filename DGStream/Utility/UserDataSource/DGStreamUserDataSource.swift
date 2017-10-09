//
//  DGStreamUserDataSource.swift
//  DGStream
//
//  Created by Brandon on 9/12/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamUserDataSource: NSObject {
    
    var selectedUsers:[DGStreamUser]!
    var userSet:Set<DGStreamUser>!
    var currentUser: DGStreamUser!
    
    init(currentUser: DGStreamUser) {
        self.currentUser = currentUser
        userSet = []
        selectedUsers = []
    }
    
    func set(users: [DGStreamUser]) -> Bool {
        
        let set = Set<DGStreamUser>.init(users)
        
        if self.userSet != set {
            self.userSet.removeAll()
            self.userSet.formUnion(set)
            
            for (index, user) in selectedUsers.enumerated() {
                if !userSet.contains(user) {
                    selectedUsers.remove(at: index)
                }
            }
            
            return true
        }
        
        return false
    }
    
    func copySelectedUsers() -> [DGStreamUser] {
        // COPY
        var users:[DGStreamUser] = []
        for u in self.selectedUsers {
            users.append(u.deepCopy())
        }
        return users
    }
    
    func selectUserAt(indexPath: IndexPath) {
        
        let user = self.usersSortedByLastSeen()[indexPath.row]
        
        if selectedUsers.contains(user), let index = selectedUsers.index(of: user) {
            selectedUsers.remove(at: index)
        }
        else {
            selectedUsers.append(user)
        }
        
    }
    
    func userWith(id: UInt) -> DGStreamUser? {
        for user in self.userSet {
            if user.userID?.uintValue == id {
                return user
            }
        }
        return nil
    }
    
    func idsFor(users: [DGStreamUser]) -> [NSNumber] {
        var ids:[NSNumber] = []
        for user in users {
            if let userID = user.userID {
                ids.append(userID)
            }
            else {
                ids.append(NSNumber(value: 0))
            }
        }
        return ids
    }
    
    func removeAllUsers() {
        self.userSet.removeAll()
    }
    
    func userSortedByFullName() -> [DGStreamUser] {
        return []
    }
    
    func unsortedUsersWithoutCurrent() -> [DGStreamUser] {
        var users:[DGStreamUser] = Array(self.userSet)
        if let index = users.index(of: self.currentUser) {
            users.remove(at: index)
        }
        var copiedUsers:[DGStreamUser] = []
        for u in users {
            copiedUsers.append(u.deepCopy())
        }
        return copiedUsers
    }
    
    func usersSortedByFullName() -> [DGStreamUser] {
        return unsortedUsersWithoutCurrent().sorted(by: { (first, second) -> Bool in
            return first.username ?? "" > second.username ?? ""
        })
    }
    
    func usersSortedByLastSeen() -> [DGStreamUser] {
        return unsortedUsersWithoutCurrent().sorted(by: { (first, second) -> Bool in
            return first.lastSeen ?? Date() > second.lastSeen ?? Date()
        })
    }
    
}

extension DGStreamUserDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersSortedByLastSeen().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DGStreamUserTableViewCell
        cell.configureWith(user: self.usersSortedByLastSeen()[indexPath.row])
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = UIColor.dgBackground()
            cell.userImageView.backgroundColor = UIColor.dgCellImageBlue()
        }
        else {
            cell.contentView.backgroundColor = UIColor.dgBackgroundHalf()
            cell.userImageView.backgroundColor = UIColor.dgCellImageGreen()
        }
        return cell
    }
}
