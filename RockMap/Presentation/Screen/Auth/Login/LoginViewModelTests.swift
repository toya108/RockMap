import Combine
import XCTest
import Resolver
@testable import RockMap
@testable import Auth

class LoginViewModelTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        Resolver.registerMockServices()
    }

    override func tearDownWithError() throws {
        Resolver.root = .mock
    }

    func testLoginIfNeeded() throws {

        XCTContext.runActivity(named: "isLoggedIn is true") { _ in
            Resolver.mock.register { MockLoggedInAuthAccessor() as AuthAccessorProtocol }

            let viewModel = LoginViewModel()

            viewModel.loginIfNeeded()

            XCTAssertTrue(viewModel.shouldChangeRootView)
        }

        XCTContext.runActivity(named: "isLoggedIn is false") { _ in
            Resolver.mock.register { MockNoLoggedInAuthAccessor() as AuthAccessorProtocol }

            let viewModel = LoginViewModel()

            viewModel.loginIfNeeded()

            XCTAssertTrue(viewModel.isPresentedAuthView)
        }
    }

    func testGuestLoginIfNeeded() throws {

        XCTContext.runActivity(named: "isLoggedIn is true") { _ in
            Resolver.mock.register { MockLoggedInAuthAccessor() as AuthAccessorProtocol }

            let viewModel = LoginViewModel()

            viewModel.guestLoginIfNeeded()

            XCTAssertTrue(viewModel.isPresentedLogoutAlert)
        }

        XCTContext.runActivity(named: "isLoggedIn is false") { _ in
            Resolver.mock.register { MockNoLoggedInAuthAccessor() as AuthAccessorProtocol }

            let viewModel = LoginViewModel()

            viewModel.guestLoginIfNeeded()

            XCTAssertTrue(viewModel.shouldChangeRootView)
        }
    }

    func testLogout() throws {

        XCTContext.runActivity(named: "succeded") { _ in
            Resolver.mock.register { MockLoggedInAuthAccessor() as AuthAccessorProtocol }

            let viewModel = LoginViewModel()

            viewModel.logout()

            XCTAssertTrue(viewModel.isPresentedDidLogoutAlert)
        }

        XCTContext.runActivity(named: "failure") { _ in
            Resolver.mock.register { MockNoLoggedInAuthAccessor() as AuthAccessorProtocol }

            let viewModel = LoginViewModel()

            viewModel.logout()

            XCTAssertTrue(viewModel.isPresentedLogoutFailureAlert)
            XCTAssertNotNil(viewModel.logoutError)
        }

    }

    func testLoginFinishedObservation() {

        XCTContext.runActivity(named: "succeded") { _ in
            Resolver.mock.register { MockAuthCoordinatorSucceded() as AuthCoordinatorProtocol }

            let viewModel = LoginViewModel()

            viewModel.authCoordinator.loginFinishedPublisher.sink { result in
                if case .success = result {
                    XCTAssertTrue(viewModel.shouldChangeRootView)
                }
            }.store(in: &cancellables)
        }

        XCTContext.runActivity(named: "failure") { _ in
            Resolver.mock.register { MockAuthCoordinatorFailed() as AuthCoordinatorProtocol }

            let viewModel = LoginViewModel()

            viewModel.authCoordinator.loginFinishedPublisher.sink { result in
                if case .failure = result {
                    XCTAssertTrue(viewModel.isPresentedAuthFailureAlert)
                    XCTAssertNotNil(viewModel.authError)
                }
            }.store(in: &cancellables)
        }
    }

}
