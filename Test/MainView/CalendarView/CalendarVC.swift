//
//  FirstView.swift
//  Test
//
//  Created by Ahmad Mohammadi on 7/29/21.
//

import UIKit
import Combine

class CalendarVC: UIViewController {
    
    private var viewModel: CalendarVM
    
    private var startDateTF: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Start Date"
        tf.borderStyle = .roundedRect
        tf.textAlignment = .center
        tf.font = UIFont.systemFont(ofSize: 15)
        return tf
    }()
    
    private var endDateTF: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "End Date"
        tf.borderStyle = .roundedRect
        tf.textAlignment = .center
        tf.font = UIFont.systemFont(ofSize: 15)
        return tf
    }()
    
    private var startDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        return dp
    }()
    
    private var endDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        return dp
    }()
    
    private var resultLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 16)
        return lbl
    }()
    
    private var cancelable = Set<AnyCancellable>()
    
    private let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    init(viewModel: CalendarVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        overrideUserInterfaceStyle = .light
        setNavTitle(.None)
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.fetchHolidays()
        viewModel.$holidays.receive(on: DispatchQueue.main).sink { _result in
        } receiveValue: {[weak self] _value in
            guard let `self` = self else {
                return
            }
            if _value.count != 0 {
                self.setupView()
            }
        }.store(in: &cancelable)
        
        viewModel.$result.receive(on: DispatchQueue.main).sink { _result in
        } receiveValue: {[weak self] _value in
            guard let `self` = self else {
                return
            }
            self.resultLbl.text = _value
        }.store(in: &cancelable)
        
        viewModel.$navBarStatus.receive(on: DispatchQueue.main).sink { _result in
        } receiveValue: {[weak self] _value in
            guard let `self` = self else {
                return
            }
            self.setNavTitle(_value)
        }.store(in: &cancelable)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // base view setup
        let tapOutside = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapOutside)
        
        view.addSubview(startDateTF)
        view.addSubview(endDateTF)
        view.addSubview(resultLbl)
        
        // view constraints
        NSLayoutConstraint.activate([
            startDateTF.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startDateTF.widthAnchor.constraint(equalToConstant: 250),
            startDateTF.heightAnchor.constraint(equalToConstant: 36),
            startDateTF.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
        
        NSLayoutConstraint.activate([
            endDateTF.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endDateTF.widthAnchor.constraint(equalToConstant: 250),
            endDateTF.heightAnchor.constraint(equalToConstant: 36),
            endDateTF.topAnchor.constraint(equalTo: startDateTF.bottomAnchor, constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            resultLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLbl.widthAnchor.constraint(equalToConstant: 280),
            resultLbl.heightAnchor.constraint(equalToConstant: 30),
            resultLbl.topAnchor.constraint(equalTo: endDateTF.bottomAnchor, constant: 20)
        ])
        
        //toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: false)
        
        // start date picker setup
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .wheels
        startDatePicker.addTarget(self, action: #selector(startDateChanged(_:)), for: .valueChanged)
        startDateTF.inputAccessoryView = toolbar
        startDateTF.inputView = startDatePicker
        
        // end date picker setup
        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .wheels
        endDatePicker.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)
        endDateTF.inputAccessoryView = toolbar
        endDateTF.inputView = endDatePicker
        
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func startDateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        startDateTF.text = formatter.string(from: sender.date)
        viewModel.setStartDate(sender.date)
    }
    
    @objc func endDateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        endDateTF.text = formatter.string(from: sender.date)
        viewModel.setEndDate(sender.date)
    }
    
    func setNavTitle(_ status: NavBarStatus) {
        
        switch status {
        case .None:
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationItem.title = "Bussiness Days Calculator"
            activityIndicator.stopAnimating()
        case .Loading:
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationItem.title = "Loading"
            let barButton = UIBarButtonItem(customView: activityIndicator)
            self.navigationItem.setRightBarButton(barButton, animated: true)
            activityIndicator.startAnimating()
        case .Error(let message):
            activityIndicator.stopAnimating()
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
            self.navigationItem.title = message
        }
        
        
    }
    
}
