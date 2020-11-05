//
//  ImageUploadPopOverTableViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/05.
//

import UIKit

class ImageUploadPopOverTableViewController: UITableViewController {

    var selectPhotoLibraryCellHandler: () -> Void = {}
    var selectCameraCellHandler: () -> Void = {}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isScrollEnabled = false
        tableView.register(UINib(nibName: ImageUploadPopOverTableViewCell.className, bundle: nil), forCellReuseIdentifier: ImageUploadPopOverTableViewCell.className)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageUploadPopOverTableViewCell.className, for: indexPath) as? ImageUploadPopOverTableViewCell else { return UITableViewCell() }
        
        switch indexPath.row {
        case 0:
            cell.howToUploadImageTitleLabel?.text = "フォトライブラリ"
            cell.howToUploadImageIconView.image = UIImage(systemName: "folder.fill")
            
        case 1:
            cell.howToUploadImageTitleLabel?.text = "写真を撮る"
            cell.howToUploadImageIconView.image = UIImage(systemName: "camera.fill")
            
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                self.selectPhotoLibraryCellHandler()
            }

        case 1:
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                self.selectCameraCellHandler()
            }
            
        default:
            break
        }
    }
}
