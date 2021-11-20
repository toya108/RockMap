import Foundation

protocol LocalRequest: RequestProtocol {
    init()
    func intercept(_ prameters: Parameters) -> Response
}
