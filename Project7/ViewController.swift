//
//  ViewController.swift
//  Project7
//
//  Created by özge kurnaz on 31.12.2024.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    
    struct DataLoader {
        func downloadData(url: URL) async -> Data? {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                return data
            } catch {
                print(error)
            }
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        downloadData(from: urlString)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(alertMessage))
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterPetitions))
    
    }
    
    
    @objc func alertMessage(){
        let ac = UIAlertController(title: nil, message: "We The People API of the Whitehouse", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func filterPetitions(){
        let ac = UIAlertController(title: nil, message: "Enter a petition" , preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac ] _ in
            guard let answer = ac?.textFields?[0].text else  {return}
            
            self?.applyFilter(answer)
                
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
        
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteredPetitions = petitions
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    
    func downloadData(from url: String) {
        guard let url = URL(string: url) else { return }

        Task {
            let dataLoader = DataLoader()
            let receviedData = await dataLoader.downloadData(url: url)
            if let data = receviedData {
                parse(json: data)
            } else {
                showError()
            }
        }
    }
    
    func applyFilter(_ keyword: String){
        let lowerAnswer = keyword.lowercased()
        
        filteredPetitions = petitions
        
        if keyword.isEmpty{
            filteredPetitions = petitions
        }else{
            filteredPetitions = petitions.filter{
                $0.title.contains(lowerAnswer) || $0.body.contains(lowerAnswer)
            }
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(filteredPetitions.count)
          return filteredPetitions.count // Petitions dizisinin eleman sayısını döndürüyoruz
      }
      
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    // connect to DetailViewController to  the table view controller.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error",
                                          message: "There was a problem loading the data. Please try again.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
