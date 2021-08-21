
import Combine
import DataLayer
//
//extension Domain.Usecase {
//
//    struct ListenPublisher<T: FSListenable>: Combine.Publisher {
//
//        typealias Output = T.Response
//        typealias Failure = Error
//
//        private let repository: Repository<T>
//        private let useTestData: Bool
//        private let paremeters: T.Parameters
//
//        init(
//            repository: Repository<T>,
//            useTestData: Bool,
//            paremeters: T.Parameters
//        ) {
//            self.repository = repository
//            self.useTestData = useTestData
//            self.paremeters = paremeters
//        }
//
//        func receive<S>(subscriber: S) where
//            S: Subscriber,
//            ListenPublisher.Failure == S.Failure,
//            ListenPublisher.Output == S.Input
//        {
//            let subscription = Subscription(
//                subscriber: subscriber,
//                repository: repository,
//                useTestData: useTestData,
//                paremeters: paremeters
//            )
//            subscriber.receive(subscription: subscription)
//        }
//
//    }
//
//}
//
//extension Domain.Usecase {
//
//    fileprivate final class Subscription<
//        SubscriberType: Subscriber,
//        U: FSListenable
//    >: Combine.Subscription where
//        SubscriberType.Input == U.Response,
//        SubscriberType.Failure == Error
//    {
//
//        private var registration: FSListenerRegistration?
//
//        init(
//            subscriber: SubscriberType,
//            repository: Repository<U>,
//            useTestData: Bool,
//            paremeters: U.Parameters
//        ) {
//            registration = repository.listen(
//                useTestData: useTestData,
//                parameters: paremeters
//            ) { result in
//                switch result {
//                    case .success(let response):
//                        _ = subscriber.receive(response)
//
//                    case .failure(let error):
//                        subscriber.receive(completion: .failure(error))
//                }
//            }
//        }
//
//        func request(_ demand: Subscribers.Demand) {}
//
//        func cancel() {
//            registration?.remove()
//            registration = nil
//        }
//    }
//}
