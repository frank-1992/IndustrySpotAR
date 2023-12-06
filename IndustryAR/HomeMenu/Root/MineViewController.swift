//
//  DownloadViewController.swift
//  IndustryAR
//
//  Created by 吴熠 on 3/20/23.
//

import UIKit
import ProgressHUD
import Zip

class MineViewController: UIViewController {
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFang-SC-Medium", size: 22)
        label.textColor = UIColor.black
        label.text = download_url.localizedString()
        label.textAlignment = .left
        return label
    }()
    
    private lazy var urlTextField: LineTextField = {
        let textField = LineTextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 4
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.black.cgColor
        textField.placeholder = ""
        textField.textColor = .black
        textField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFang-SC-Medium", size: 22)
        label.textColor = UIColor.black
        label.text = file_password.localizedString()
        label.textAlignment = .left
        return label
    }()
    
    private lazy var passwordView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    private lazy var passwordTextField: LineTextField = {
        let textField = LineTextField()
        textField.backgroundColor = .white
        textField.placeholder = ""
        textField.textColor = .black
        return textField
    }()
    
    private lazy var secretButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "xianshimima"), for: .normal)
        button.addTarget(self, action: #selector(passwordState(sender:)), for: .touchUpInside)
        button.tag = 1000
        return button
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFang-SC-Medium", size: 18)
        label.textColor = UIColor.systemPink
        label.text = "0%"
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray2
//        button.isUserInteractionEnabled = false
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle(download.localizedString(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFang-SC-Medium", size: 20)
        button.addTarget(self, action: #selector(downloadAsset), for: .touchUpInside)
        return button
    }()
    
    var zipPassword: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(view).offset(300)
            make.left.equalTo(view).offset(50)
        }
        
        view.addSubview(urlTextField)
        urlTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(30)
            make.left.equalTo(nameLabel)
            make.right.equalTo(view).offset(-50)
            make.height.equalTo(44)
        }
        
        view.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
            make.left.equalTo(urlTextField)
            make.top.equalTo(urlTextField.snp.bottom).offset(8)
        }
        
        view.addSubview(passwordLabel)
        passwordLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(urlTextField).offset(100)
        }
        
        view.addSubview(passwordView)
        passwordView.snp.makeConstraints { make in
            make.left.height.equalTo(urlTextField)
            make.top.equalTo(passwordLabel.snp.bottom).offset(30)
            make.width.equalTo(200)
        }
        
        passwordView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(passwordView)
            make.width.equalTo(150)
        }
        
        passwordView.addSubview(secretButton)
        secretButton.snp.makeConstraints { make in
            make.right.equalTo(passwordView).offset(-10)
            make.centerY.equalTo(passwordView)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        view.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(passwordTextField.snp.bottom).offset(80)
            make.size.equalTo(CGSize(width: 160, height: 50))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @objc
    private func passwordState(sender: UIButton) {
        if sender.tag == 1000 {
            sender.setBackgroundImage(UIImage(named: "yincangmima"), for: .normal)
            sender.tag = 1001
            passwordTextField.isSecureTextEntry = true
        } else {
            sender.setBackgroundImage(UIImage(named: "xianshimima"), for: .normal)
            sender.tag = 1000
            passwordTextField.isSecureTextEntry = false
        }
    }
    
    @objc
    private func textFieldChanged(textField: LineTextField) {
        if let text = textField.text, !text.isEmpty, validateText(validatedType: .url, validateString: text) {
            downloadButton.backgroundColor = .systemRed
            downloadButton.isUserInteractionEnabled = true
        } else {
            downloadButton.backgroundColor = .systemGray2
            downloadButton.isUserInteractionEnabled = false
        }
    }
    
    @objc
    private func downloadAsset() {
        // https://github.com/marmelroy/Zip
        view.endEditing(true)
        zipPassword = nil
        guard let urlString = urlTextField.text, !urlString.isEmpty else { return }
        if let password = passwordTextField.text, !password.isEmpty {
            zipPassword = password
        }
        progressLabel.isHidden = false
        DownloaderManager.shared.download(url: URL(string: urlString)!, progress: { (progress) in
            DispatchQueue.main.async {
                self.progressLabel.text = String(Int(progress * 100))+"%"
                if progress == 1 {
                    self.progressLabel.text = download_success.localizedString()
                }
            }
            
        }, completion: { (filePath, fileName) in
            self.unzipFile(filePath: filePath, fileName: fileName)
        }) { (error) in
            DispatchQueue.main.async {
                self.progressLabel.text = download_fail.localizedString()
                ProgressHUD.failed(download_fail.localizedString())
            }
        }
    }
    
    private func unzipFile(filePath: String, fileName: String) {
        guard let fileURL = URL(string: filePath) else { return }
        do {
            let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(containerName, isDirectory: true)
            try Zip.unzipFile(fileURL, destination: dirURL, overwrite: true, password: zipPassword, progress: { progress in
                if progress >= 1.0 {
                    DispatchQueue.main.async {
                        ProgressHUD.succeed(decompression.localizedString())
                        self.passwordTextField.text = ""
                    }
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {}
                }
            })
        } catch {
            print("Something went wrong")
            DispatchQueue.main.async {
                ProgressHUD.failed(decompression_fail.localizedString())
                self.passwordTextField.text = ""
            }
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {}
        }
    }
}
