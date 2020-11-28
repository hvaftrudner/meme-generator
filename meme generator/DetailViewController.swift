//
//  DetailViewController.swift
//  meme generator
//
//  Created by Kristoffer Eriksson on 2020-11-25.
//

import UIKit

class DetailViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    
    weak var delegate: ViewController!
    
    var memes = [Meme]()
    
    var image : UIImage?
    var meme : Meme?
    var path : String?
    var memeName : String?
    var memeIndex : Int?
    
    var topText: String?
    var bottomText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self

        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteMeme))
    
        
        if let imageToLoad = image{

            imageView.image = imageToLoad

        }
      
        
    }
    
    //button methods
    @IBAction func resetImage(_ sender: Any) {
        guard let image = image else {return}
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: image.size.width, height: image.size.height))
        let renderedImage = renderer.image { ctx in
            //graphics code
            
            print(image.size)
            //image first to set lower zposition
            image.draw(at: CGPoint(x: 0, y: 0))
                        
        }
        
        topText = ""
        bottomText = ""
        
        imageView.image = renderedImage
    }
    @IBAction func saveImage(_ sender: Any) {
        
        //add name to picture
        let ac = UIAlertController(title: "Name masterpiece", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default){
            [weak self] _ in
            guard let nameText = ac.textFields?[0].text else {return}
            self?.memeName = nameText
            
            
            self?.save()
            
            self?.navigationController?.popViewController(animated: true)
            
            
        })
        present(ac, animated: true)
        
    }
    
    @IBAction func addTopText(_ sender: Any) {
        
        //guard let imageWithTop = imageView.image else {return}
        
        let ac = UIAlertController(title: "Set Top Text", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Ok", style: .default){
            [weak self]_ in
            guard let topText = ac.textFields?[0].text else {return}
            self?.topText = topText
            
            //self?.drawText(image: imageWithTop, text: topText, position: 20)
            self?.renderPicture()
        
        })
        
        present(ac, animated: true)
        
    }
    
    @IBAction func addBottomText(_ sender: Any) {
        //guard let imageWithTop = imageView.image else {return}
        
        let ac = UIAlertController(title: "Set Bottom Text", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Ok", style: .default){
            [weak self]_ in
            guard let bottomText = ac.textFields?[0].text else {return}
            self?.bottomText = bottomText
            
            self?.renderPicture()
            
        
        })
        
        present(ac, animated: true)
    }
    //Add an image function like "AddCaption"
    func renderPicture(){
        
        guard let image = imageView.image else {return}
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: image.size.width, height: image.size.height))
        let renderedImage = renderer.image { [weak self] ctx in
            //graphics code
            
            print(image.size)
            //image first to set lower zposition
            image.draw(at: CGPoint(x: 0, y: 0))
            
            if let imageToTop = self?.topText{
                self?.drawText(image: image, text: imageToTop, position: 20)
            }
            if let imageToBottom = self?.bottomText{
                self?.drawText(image: image, text: imageToBottom, position: 400)
            }
                        
        }
        
        imageView.image = renderedImage
    }
    
    //add text methods
    func drawText(image: UIImage, text: String, position: CGFloat) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attrs : [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 45),
            .paragraphStyle: paragraphStyle,
            //got an -[__NSCFType set]: unrecognized selector sent to instance" error when
            //using .cgColor here
            .foregroundColor: UIColor.white,
            
        ]
        print(text)
        
        let attributedString = NSAttributedString(string: text, attributes: attrs)
        
        attributedString.draw(with: CGRect(x: 180, y: position, width: 400, height: 200), options: .usesLineFragmentOrigin, context: nil)
        //text.draw(with: CGRect(x: image.size.width / 2, y: 50, width: 100, height: 100), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
                        
    }
    // Save
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func save(){
        
        //overwriting image
        if let image = imageView.image {
            if let data = image.jpegData(compressionQuality: 0.8) {
                let filename = getDocumentsDirectory().appendingPathComponent(path!)
                try? data.write(to: filename)
            }
        }
        meme?.name = memeName!
        meme?.bottomText = bottomText
        meme?.topText = topText
        memes.append((meme)!)
        
        let jsonEncoder = JSONEncoder()
        if let savedPictures = try? jsonEncoder.encode(memes){
            let defaults = UserDefaults.standard
            defaults.set(savedPictures, forKey: "memes")
        } else {
            print("could not save pictures")
        }
    }
    
    @objc func deleteMeme(){
        memes.remove(at: memeIndex!)
        
        navigationController?.popViewController(animated: true)
    }
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let vc = viewController as? ViewController {
            
            vc.memes = memes
            vc.save()
            vc.collectionView.reloadData()
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
