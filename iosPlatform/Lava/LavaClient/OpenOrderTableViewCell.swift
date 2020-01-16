//
//  OpenOrderTableViewCell.swift
//  LavaClient
//
//  Copyright © 2018 JNJ. All rights reserved.
//

import UIKit

class OpenOrderTableViewCell: UITableViewCell {

    var indicatorColor = UIColor.blue{
        didSet{
            updateUI()
        }
    }

    @IBOutlet private weak var locationImage: UIImageView!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var consumerLablel: UILabel!
    @IBOutlet private weak var descriptionLable: UILabel!

    //the order represented by this cell
    public var order: Order?{
        didSet{
            updateUI()
        }
    }

    func updateUI(){
        locationLabel?.text = order?.location
        locationLabel?.textColor = indicatorColor
        descriptionLable?.text = order?.description
        descriptionLable?.textColor = indicatorColor

        if let consumer = order?.consumer{
            ClientRequests.getProfile(profileId: consumer){
                self.consumerLablel?.text = "\($0.name): \($0.handle)"
            }

            consumerLablel?.text = String(consumer)
            consumerLablel?.textColor = indicatorColor
        }

        if let building = order?.location{
            DispatchQueue.global().async { [weak self] in
                let url = "https://student-life.williams.edu/files/2014/02/" + building + ".jpg"
                if let imageData = try? Data(contentsOf: URL(string: url)!) {
                    DispatchQueue.main.async {
                        if url == "https://student-life.williams.edu/files/2014/02/" + (self?.order?.location)! + ".jpg"{
                            self?.locationImage?.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
