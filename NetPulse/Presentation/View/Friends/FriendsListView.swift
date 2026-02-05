//
//  FriendsListView.swift
//  NetPulse
//

import SwiftUI

struct FriendsListView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        NavigationView {
            List(userManager.allUsers.filter { $0.id != userManager.currentUser?.id }) { user in
                HStack {
                    Text(user.name)
                    Spacer()
                    Text(user.status.description)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Друзья")
        }
    }
}
