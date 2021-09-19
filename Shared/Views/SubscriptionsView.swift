import SwiftUI

struct SubscriptionsView: View {
    @ObservedObject private var store = Store<[Video]>()

    var resource = InvidiousAPI.shared.feed

    init() {
        resource.addObserver(store)
    }

    var body: some View {
        VideosView(videos: store.collection)
            .onAppear {
                resource.loadIfNeeded()
            }
            .refreshable {
                resource.load()
            }
        #if !os(tvOS)
            .navigationTitle("Subscriptions")
        #endif
    }
}