//
//  EmiCalculatorViewController.swift
//  EmiCalculator
//
//  Created by Tirupati Balan on 11/04/16.
//  Copyright (c) 2016 CelerStudio. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit
import GoogleMobileAds

protocol EmiCalculatorViewControllerInput
{
    func displaySomething(_ viewModel: EmiCalculatorViewModel)
}

protocol EmiCalculatorViewControllerOutput
{
    func doSomething(_ request: EmiCalculatorRequest)
}

class EmiCalculatorViewController: UIViewController, EmiCalculatorViewControllerInput, UITextFieldDelegate
{
    var output: EmiCalculatorViewControllerOutput!
    var router: EmiCalculatorRouter!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalInterestPayableLabel: UILabel!
    @IBOutlet var totalPaymentInterestPlusPrincipalLabel: UILabel!
    @IBOutlet var loanEmiLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var loanTenureVal: NSInteger = 0;
    var interestRateVal: Double = 0;
    var amountVal: Double = 0;
    
    // MARK: Object lifecycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        EmiCalculatorConfigurator.sharedInstance.configure(viewController: self)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "EMI Calculator"
        
        bannerView.adUnitID = "ca-app-pub-4961045217927492/7307627166"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    // MARK: Event handling
    
    func calculateEmiAction(_ amount : String)
    {
        // NOTE: Ask the Interactor to do some work
        let loanAmountVal = Double(amount)
        
        let requestEmiCalculationVal = EmiCalculatorRequest.RequestEmiCalculation(loanAmount : loanAmountVal!, loanTenure: self.loanTenureVal, interestRate: self.interestRateVal);
        let request = EmiCalculatorRequest(requestEmiCalculation : requestEmiCalculationVal)
        output.doSomething(request)
    }
    
    // MARK: Display logic
    
    func displaySomething(_ viewModel: EmiCalculatorViewModel)
    {
        // NOTE: Display the result from the Presenter
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current

        self.totalPaymentInterestPlusPrincipalLabel.text = formatter.string(from: NSNumber(value: viewModel.emiCalculation.totalPayment.isNaN ? 0 : viewModel.emiCalculation.totalPayment))
        self.totalInterestPayableLabel.text = formatter.string(from: NSNumber(value: viewModel.emiCalculation.totalPaymentInterest.isNaN ? 0 : viewModel.emiCalculation.totalPaymentInterest))
        self.loanEmiLabel.text = formatter.string(from: NSNumber(value: viewModel.emiCalculation.loanEmi.isNaN ? 0 : viewModel.emiCalculation.loanEmi))
    }
    
    func returnCellForIndexPath(_ indexPath : IndexPath) -> UITableViewCell! {
        return self.tableView.cellForRow(at: indexPath)! as UITableViewCell
    }
    
    func returnAmountField() -> UITextField {
        return self.returnCellForIndexPath(IndexPath.init(row: 0, section: 0)).viewWithTag(111) as! UITextField
    }
    
    func returnLoanTenureField() -> UITextField {
        return self.returnCellForIndexPath(IndexPath.init(row: 1, section: 0)).viewWithTag(221) as! UITextField
    }
    
    func returnLoanTenureSlider() -> UISlider {
        return self.returnCellForIndexPath(IndexPath.init(row: 1, section: 0)).viewWithTag(222) as! UISlider
    }
    
    func returnInterestRateField() -> UITextField {
        return self.returnCellForIndexPath(IndexPath.init(row: 2, section: 0)).viewWithTag(331) as! UITextField
    }
    
    func returnInterestRateSlider() -> UISlider {
        return self.returnCellForIndexPath(IndexPath.init(row: 2, section: 0)).viewWithTag(332) as! UISlider
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        switch ((indexPath as NSIndexPath).row) {
        case 0:
            return 80;
        case 1:
            return 90;
        case 2:
            return 90;
        case 3:
            return 100;
        default:
            break;
        }
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (self.tableView!.dequeueReusableCell(withIdentifier: "cell\((indexPath as NSIndexPath).row)")! as UITableViewCell)
        
        self.configureCellForTableView(tableView, withCell: cell, withIndexPath: indexPath)
        return cell
    }
    
    func configureCellForTableView(_ tableView: UITableView, withCell cell: UITableViewCell, withIndexPath indexPath: IndexPath) {
        switch ((indexPath as NSIndexPath).row) {
        case 0:
            let textField:UITextField = cell.viewWithTag(111) as! UITextField
            textField.delegate = self
            
            break;
        case 1:
            let loanTenureSlider:UISlider = cell.viewWithTag(222) as! UISlider
            loanTenureSlider.addTarget(self, action: #selector(EmiCalculatorViewController.sliderValueDidChange(_:)), for: .valueChanged)
            break;
        case 2:
            let interestRateSlider:UISlider = cell.viewWithTag(332) as! UISlider
            interestRateSlider.addTarget(self, action: #selector(EmiCalculatorViewController.sliderValueDidChange(_:)), for: .valueChanged)
        default:
            break;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        print("You selected cell #\((indexPath as NSIndexPath).row)!")
    }
    
    func applyRedBorderOnAmount() {
        self.returnAmountField().layer.borderColor = UIColor.red.cgColor
        self.returnAmountField().layer.borderWidth = 1;
        self.returnAmountField().layer.cornerRadius = 5;
    }
    
    func clearRedBorderOnAmount() {
        self.returnAmountField().layer.borderColor = UIColor.clear.cgColor
        self.returnAmountField().layer.borderWidth = 0;
        self.returnAmountField().layer.cornerRadius = 0;
    }
    
    func validateAmountField() -> Bool {
        if (self.returnAmountField().text == nil || self.returnAmountField().text == "") {
            self.applyRedBorderOnAmount();
            self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            
            self.returnLoanTenureSlider().value = Float(self.loanTenureVal)
            self.returnInterestRateSlider().value = Float(self.interestRateVal)
            return false
        } else {
            self.clearRedBorderOnAmount()
            return true
        }
    }
    
    func sliderValueDidChange(_ sender: UISlider) {
        if (!validateAmountField()) {
            return
        }
        
        switch (sender.tag)
        {
        case 222:
            self.loanTenureVal = Int(floor(sender.value))
            returnLoanTenureField().text = String(format :"%.0f years", floor(sender.value))
            break;
        case 332:
            self.interestRateVal = Double(floor(sender.value))
            returnInterestRateField().text = String(format : "%.0f", floor(sender.value))
            break;
        default:
            break;
        }
        calculateEmiAction(self.returnAmountField().text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.tableView.scrollRectToVisible(CGRect(x: 0, y: 48, width: self.tableView.frame.size.width, height: self.tableView.frame.size.width), animated: true)
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let filtered = string.components(separatedBy: CharacterSet(charactersIn:"0123456789").inverted).joined(separator: "")
        if (string == filtered) {
            var txtAfterUpdate: NSString = textField.text! as NSString
            txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
            
            if (textField.tag == 331) { //Interest Rate Text Field
                self.interestRateVal = txtAfterUpdate.doubleValue
                calculateEmiAction(String(format : "%.0f", floor(self.amountVal)))
            } else { //Amount Text Field
                self.clearRedBorderOnAmount();
                self.amountVal = txtAfterUpdate.doubleValue
                calculateEmiAction(String(format : "%.0f", floor(self.amountVal)))
            }
            return true
        } else {
            return false
        }
    }
}
