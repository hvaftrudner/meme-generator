//
//  ViewController.swift
//  meme generator
//
//  Created by Kristoffer Eriksson on 2020-11-25.
//

import UIKit

class ViewController: UICollectionViewController,
                      UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //custom class array
    var memes = [Meme]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        load()
        // add navigation controller to import photo
        let addpicture = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addNewPicture))
        navigationItem.leftBarButtonItems = [addpicture]
    }

    //collectionview
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as? MemeCell else {
            fatalError("could not load cell")
        }
        let chosenPic = memes[indexPath.item]
        let path = getDocumentsDirectory().appendingPathComponent(chosenPic.image)
        
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.black.cgColor
        
        save()
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //select item in list
        let item = memes[indexPath.item]
        
        if let vc = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController {
            
            let path = getDocumentsDirectory().appendingPathComponent(item.image)
            vc.image = UIImage(contentsOfFile: path.path)
            
            vc.meme = item
            vc.path = item.image
            vc.memes = memes
            
            vc.delegate = self
            
            vc.memeIndex = memes.firstIndex(of: item)
            
            navigationController?.pushViewController(vc, animated: true)
        }
        collectionView.reloadData()
    }
    
    // helper methods
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // do stuff
        guard let image = info[.editedImage] as? UIImage else {return}
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        
        let picture = Meme(name: "name", topText: "topText", bottomText: "bottomText", image: imageName)
        memes.append(picture)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    @objc func addNewPicture(){
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }
        
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // save & load
    func save(){
        let jsonEncoder = JSONEncoder()
        if let savedPictures = try? jsonEncoder.encode(memes){
            let defaults = UserDefaults.standard
            defaults.set(savedPictures, forKey: "memes")
        } else {
            print("could not save pictures")
        }
    }
    func load(){
        let defaults = UserDefaults.standard
        if let savedPictures = defaults.object(forKey: "memes") as? Data {
            
            let jsonDecoder = JSONDecoder()
            do {
                memes = try jsonDecoder.decode([Meme].self, from: savedPictures)
                    
            } catch {
                print("failed to load pictures")
            }
            
        }
    }
}

