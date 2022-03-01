//
//  FeedViewController.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/21/22.
//

import UIKit

class FeedViewController: UIViewController {
    
    private let pageSize = 20
    private var collectionView: UICollectionView?
    private var viewModels = [[FeedCellType]]()
    private var likedImagesDict: [String:Bool] = [:]
    private var breed: DogsBreed = .pug {
        didSet {
            viewModels = [[FeedCellType]]()
            configureForNewBreed()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .label
        configureCollectionView()
        configureNavItems()
        configureForNewBreed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func configureForNewBreed() {
        title = breed.getTitle()
        fetchDogs()
    }
}

extension FeedViewController {
    private func configureCollectionView() {
        let likesCellHeight: CGFloat = 50
        let spinnerCellHeight: CGFloat = 50
        let sectionHeight: CGFloat = view.frame.width + likesCellHeight + spinnerCellHeight
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in
                //Cell for image
                let imageItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)
                    )
                )
                
                //Cell for likes
                let likesItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(likesCellHeight)
                    )
                )
                
                //Cell for spinner
                let spinnerItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(spinnerCellHeight)
                    )
                )
        
                //Group
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(sectionHeight)
                    ),
                    subitems: [imageItem, likesItem, spinnerItem])
                
                //Section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
                
                return section
            })
        )
        
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.register(LikesCollectionViewCell.self,
                                forCellWithReuseIdentifier: LikesCollectionViewCell.identifier)
        collectionView.register(SpinnerCollectionViewCell.self,
                                forCellWithReuseIdentifier: SpinnerCollectionViewCell.identifier)
    }
    
    private func configureNavItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapNavBarItem))
    }
}

extension FeedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //to show spinner cell
        if DogsAPI.shared.isFetchingData && section == viewModels.count - 1 {
            return viewModels[section].count + 1
        }
        
        return viewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //handle spinner, last row of last section
        if viewModels[indexPath.section].count <= indexPath.row {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpinnerCollectionViewCell.identifier,
                                                                for: indexPath) as? SpinnerCollectionViewCell else {
                fatalError()
            }
            cell.startSpinning()
            return cell
        }
        
        let cellType = viewModels[indexPath.section][indexPath.row]
        
        switch cellType {
        case .image(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier,
                                                                for: indexPath) as? ImageCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .likes(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikesCollectionViewCell.identifier,
                                                                for: indexPath) as? LikesCollectionViewCell else {
                fatalError()
            }
            
            var newViewModel = viewModel
            //check if is liked
            if let isLiked = likedImagesDict[viewModel.imageUrlString] {
                if isLiked {
                    newViewModel.isLiked = true
                    newViewModel.likesCount += 1
                }
            }
            
            cell.delegate = self
            cell.configure(with: newViewModel)
            return cell
        }
    }
    
    func fetchDogs(additionalLoad: Bool = false) {
        guard !additionalLoad || !DogsAPI.shared.isFetchingData else { return }
        
        DispatchQueue.main.async {[weak self] in
            self?.collectionView?.reloadData()
        }
        
        DogsAPI.shared.getDogs(breed: breed, pageSize: pageSize, completion: {[weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let dogsViewModels):
                self?.viewModels.append(contentsOf: dogsViewModels)
            }
            
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        })
    }
}

extension FeedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView else { return }
        
        let position = scrollView.contentOffset.y
        if position > collectionView.contentSize.height - 100 - scrollView.frame.height{
            fetchDogs(additionalLoad: true)
        }
    }
}

extension FeedViewController: ImageCollectionViewCellDelegate, LikesCollectionViewCellDelegate {
    private func changeLikeCountFor(imageUrlString: String, isLiked: Bool) {
        if isLiked {
            likedImagesDict[imageUrlString] = true
        } else if likedImagesDict[imageUrlString] != nil {
            likedImagesDict[imageUrlString] = false
        }
    }
    
        
    func likesCollectionViewCellDidLikeChanged(_ cell: LikesCollectionViewCell, isLiked: Bool) {
        guard let imageUrlString = cell.viewModel?.imageUrlString else { return }
        
        changeLikeCountFor(imageUrlString: imageUrlString, isLiked: isLiked)
    }
    
    func imageCollectionViewCellDidLikeChanged(_ cell: ImageCollectionViewCell, isLiked: Bool) {
        guard let imageUrlString = cell.viewModel?.imageURL.absoluteString else { return }
        
        changeLikeCountFor(imageUrlString: imageUrlString, isLiked: isLiked)
        
        //refresh table
        DispatchQueue.main.async {[weak self] in
            self?.collectionView?.reloadData()
        }
    }
}

//picker view methods
extension FeedViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    @objc private func didTapNavBarItem() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: view.frame.width - 20, height: 200)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(getSelectedRow(), inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        
        let alert = UIAlertController(title: "Select Dog Breed", message: "", preferredStyle: .actionSheet)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { [weak self] (UIAlertAction) in
            self?.setSelectedBreed(forRow: pickerView.selectedRow(inComponent: 0))
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setSelectedBreed(forRow: Int) {
        let newSelection = DogsBreed.allCases[forRow]
        if newSelection != breed {
            breed = newSelection
        }
    }
    
    func getSelectedRow() -> Int {
        if let index = DogsBreed.allCases.firstIndex(of: breed) {
            return index
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let screenWidth = self.view.frame.width - 10
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 190))
        label.text = DogsBreed.allCases[row].getTitle()
        label.sizeToFit()
        
        return label
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DogsBreed.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
}
