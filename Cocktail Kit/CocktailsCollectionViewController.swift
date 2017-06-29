//
//  CocktailsCollectionViewController.swift
//  Cocktail Kit
//
//  Created by Thibault Deutsch on 15/06/2017.
//  Copyright © 2017 ATKF. All rights reserved.
//

import UIKit
import AlgoliaSearch
import AlamofireImage

private let reuseIdentifier = "CocktailCell"

private let itemsPerRow: CGFloat = 2
private let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

class CocktailsCollectionViewController: UICollectionViewController {

    var cocktails = [CocktailRecord]()

    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()

        // Quick hack to have a filter button
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(#imageLiteral(resourceName: "Filter Icon [Normal]"), for: .bookmark, state: .normal)
        searchController.searchBar.setImage(#imageLiteral(resourceName: "Filter Icon [Highlighted]"), for: .bookmark, state: .highlighted)

        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true

        SearchService.shared.search(query: "") { (cocktails) in
            self.cocktails = cocktails
            self.collectionView?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func favoriteDoubleTap(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }

        let point = sender.location(in: collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: point) {
            cocktails[indexPath.row].toggleFavorite()
            collectionView?.reloadItems(at: [indexPath])
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CocktailDetailTableViewController, let indexPath = collectionView?.indexPathsForSelectedItems?.first {
            destination.cocktail = cocktails[indexPath.row]
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cocktails.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CocktailViewCell

        let cocktail = cocktails[indexPath.row]
        cell.setCocktail(cocktail)
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)

            return headerView
        }

        return UICollectionReusableView()
    }
}

extension CocktailsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth /  itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension CocktailsCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            SearchService.shared.search(query: searchText) { (cocktails) in
                self.cocktails = cocktails
                self.collectionView?.reloadData()
            }
        }
    }
}
