enum LoadableViewState {
    case stanby
    case loading
    case finish
    case failure(Error?)
}
