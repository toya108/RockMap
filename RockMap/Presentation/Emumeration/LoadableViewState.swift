enum LoadableViewState {
    case standby
    case loading
    case finish
    case failure(Error?)
}
