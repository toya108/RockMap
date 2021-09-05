import DataLayer

public extension Domain.Usecase.Image {
    typealias Image = Domain.Usecase.Image

    struct Header {
        public typealias Fetch = Image.Fetch<Repositories.Storage.Header.Fetch>
        public typealias Set = Image.Set.Header
        public typealias Delete = Image.Delete.Header
        public typealias Write = Image.Write<Image.Set.Header, Image.Delete.Header>

    }
    struct Icon {
        public typealias Fetch = Domain.Usecase.Image.Fetch<Repositories.Storage.Icon.Fetch>
        public typealias Set = Image.Set.Icon
        public typealias Delete = Image.Delete.Icon
        public typealias Write = Image.Write<Image.Set.Icon, Image.Delete.Icon>
    }
}
