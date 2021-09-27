import UIKit

extension MyPageViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {

        let headerImageCellRegistration = createHeaderImageCell()
        let userCellRegistration = createUserCell()
        let socialLinkCellRegistration = createSocialLinkCell()
        let introductionCellRegistration = createIntroductionCell()
        let climbedNumberCellRegistration = createClimbedNumberCell()
        let listCellRegistration = createListCell()
        let noCourseCellRegistration = createNoCourseCell()
        let courseCellRegistration = createCourseCell()

        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            switch item {
            case .headerImage:
                return collectionView.dequeueConfiguredReusableCell(
                    using: headerImageCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case .user:
                return self.collectionView.dequeueConfiguredReusableCell(
                    using: userCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .socialLink(socialLink):
                return collectionView.dequeueConfiguredReusableCell(
                    using: socialLinkCellRegistration,
                    for: indexPath,
                    item: socialLink
                )

            case .introduction:
                return collectionView.dequeueConfiguredReusableCell(
                    using: introductionCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case .climbedNumber:
                return collectionView.dequeueConfiguredReusableCell(
                    using: climbedNumberCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .registeredRock(kind), let .registeredCourse(kind):
                return collectionView.dequeueConfiguredReusableCell(
                    using: listCellRegistration,
                    for: indexPath,
                    item: kind
                )

            case .noCourse:
                return collectionView.dequeueConfiguredReusableCell(
                    using: noCourseCellRegistration,
                    for: indexPath,
                    item: Dummy()
                )

            case let .climbedCourse(course):
                return collectionView.dequeueConfiguredReusableCell(
                    using: courseCellRegistration,
                    for: indexPath,
                    item: course
                )
            }
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in

            guard let self = self else { return }

            supplementaryView.setSideInset(0)
            supplementaryView.label.text = self.snapShot.sectionIdentifiers[indexPath.section]
                .headerTitle
        }

        datasource.supplementaryViewProvider = { [weak self] _, _, index in

            guard let self = self else { return nil }

            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: index
            )
        }

        return datasource
    }

    private func createHeaderImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard let self = self else { return }

            guard case .finish = self.viewModel.output.fetchUserState else { return }

            cell.imageView.loadImage(
                url: self.viewModel.output.fetchUserState.content?.headerUrl
            )
        }
    }

    private func createUserCell() -> UICollectionView.CellRegistration<
        UserCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: UserCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in

            guard let self = self else { return }

            switch self.viewModel.userKind {
            case .guest:
                cell.editProfileButton.isHidden = true
                cell.userView.userNameLabel.text = "ゲスト"
                cell.userView.registeredDateLabel.isHidden = true

            case .mine, .other:
                cell.editProfileButton.isHidden = !self.viewModel.userKind.isMine

                guard let user = self.viewModel.output.fetchUserState.content else { return }

                cell.userView.configure(
                    user: user,
                    registeredDate: user.createdAt,
                    parentVc: self
                )

                cell.editProfileButton.addActionForOnce(
                    .init { [weak self] _ in

                        guard
                            let self = self,
                            let user = self.viewModel.output.fetchUserState.content
                        else {
                            return
                        }

                        self.router.route(to: .editProfile(user), from: self)
                    },
                    for: .touchUpInside
                )
            }
        }
    }

    private func createSocialLinkCell() -> UICollectionView.CellRegistration<
        SocialLinkCollectionViewCell,
        Entity.User.SocialLinkType
    > {
        .init { [weak self] cell, _, socialLinkType in

            guard let self = self else { return }

            var socialLink: Entity.User.SocialLink {
                guard
                    let user = self.viewModel.output.fetchUserState.content,
                    let socialLink = user.socialLinks.getLink(type: socialLinkType)
                else {
                    return .init(linkType: socialLinkType, link: "")
                }
                return socialLink
            }

            cell.configure(for: socialLink)
        }
    }

    private func createIntroductionCell() -> UICollectionView.CellRegistration<
        LabelCollectionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in

            guard
                let self = self,
                let user = self.viewModel.output.fetchUserState.content
            else {
                return
            }

            cell.label.text = user.introduction
        }
    }

    private func createClimbedNumberCell() -> UICollectionView.CellRegistration<
        ClimbedNumberCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: ClimbedNumberCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in

            guard let self = self else { return }

            cell.configure(
                total: self.viewModel.output.climbedList.count,
                flash: self.viewModel.output.climbedList.filter(\.type.isFlash).count,
                redPoint: self.viewModel.output.climbedList.filter(\.type.isRedpoint).count
            )
        }
    }

    private func createListCell() -> UICollectionView.CellRegistration<
        UICollectionViewListCell,
        ItemKind.RegisteredKind
    > {
        .init { cell, _, kind in
            var content = cell.defaultContentConfiguration()
            content.imageProperties.maximumSize = CGSize(width: 24, height: 24)
            content.imageProperties.tintColor = .black
            content.image = kind.iconImage
            content.text = kind.cellTitle
            cell.contentConfiguration = content
        }
    }

    private func createNoCourseCell() -> UICollectionView.CellRegistration<
        NoCoursesCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: NoCoursesCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, _ in
            cell.titleLabel.text = "まだ登った課題はありません。"
            cell.addCourseButton.isHidden = true
        }
    }

    private func createCourseCell() -> UICollectionView.CellRegistration<
        CourseCollectionViewCell,
        Entity.Course
    > {
        .init(
            cellNib: .init(
                nibName: CourseCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, course in

            guard let self = self else { return }

            cell.configure(course: course, parentVc: self)
        }
    }
}
