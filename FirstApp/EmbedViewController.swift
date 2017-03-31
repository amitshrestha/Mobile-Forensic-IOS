//
//  EmbedViewController.swift
//  FirstApp
//
//  Created by Amit on 3/30/17.
//  Copyright © 2017 Amit. All rights reserved.
//

import Foundation
import UIKit

class EmbedViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
 
    @IBOutlet weak var coverImage: UIImageView!
    
    
    @IBOutlet weak var stegoImage: UIImageView!
    
    @IBOutlet weak var secretMessageField: UITextField!
    
    @IBOutlet weak var retrievedMessageField: UILabel!
    
    @IBAction func retrieveButton(sender: AnyObject) {
        
        retrieve_secret_message()
    }
    
    @IBAction func embedButton(sender: AnyObject) {
        var message_to_embed : String!
        message_to_embed = secretMessageField.text
        embedMessage(String(message_to_embed))
    }
    
    func embedMessage(message: String){
        print(message)
        let length_of_message = message.characters.count
        //find red pixels        
        var red_pixel_array = [Int]()
        
        let cImage = coverImage.image
        let myRGBA = RGBAImage(image: cImage!)!
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width{
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                red_pixel_array.append(Int(pixel.red))
                
            }
        }
        
        //embed message in lsb of red pixels
        let singleCharString = message as NSString
        var counter = 0
        
        for i in 0..<length_of_message{
            let singleChar = singleCharString.characterAtIndex(i)
            var message_binary = get_binary(Int(singleChar))
            
            print("Single Character")
            print(singleChar)
            print(message_binary)
            
            let binary_length = message_binary.characters.count
            
            for j in 0..<(binary_length){
                let message_bit = Int(message_binary)! % 10 //for eg last bit of message is 1
                let msg_bit_with_ones = pad_one(String(message_bit), toSize: 8) // var message_bit_to_binary = get_binary(message_bit)  // this will append 1's in the front to become 11111111
                let msg_bit_with_zeros = pad_zero(String(message_bit), toSize: 8) // var message_bit_to_binary = get_binary(message_bit)  // this will append 1's in the front to become 00000001
                let int_number = strtoul(msg_bit_with_ones, nil, 2) // convert above binary number to int
                let int_number1 = strtoul(msg_bit_with_zeros, nil, 2) // convert above binary number to int
                
                let pixel_to_change = red_pixel_array[counter]
                var lsb_changed_pixel = 255
                if(message_bit == 1){
                    print("number with zeros")
                    print(int_number1)
                    lsb_changed_pixel = Int(pixel_to_change) | Int(int_number1)
                }else{
                    print("number with ones")
                    print(int_number)
                    lsb_changed_pixel = Int(pixel_to_change) & Int(int_number)
                }
                
                red_pixel_array[counter] = Int(lsb_changed_pixel)
                message_binary = String((Int(message_binary)!)/10)
                
                print("message bit")
                print(message_bit)
                print(msg_bit_with_ones)

                print("pixel infor")
                print(get_binary(pixel_to_change))
                print(pixel_to_change)
                print(lsb_changed_pixel)
                
                counter += 1
                
            }
        }
        draw_stego_image(red_pixel_array, length: length_of_message, myRGBA: myRGBA)
    }
    
    func draw_stego_image(var red_pixels: [Int], var length: Int, var myRGBA: RGBAImage){
        var counter = 0
        for y in 0..<myRGBA.height {
            for x in 0..<(myRGBA.width){
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]

                pixel.red = UInt8(red_pixels[counter])
                if(counter == 0){
                    
                    //green pixel to save the length of message at first pixel so that the length value can be used to extract secret message
                    pixel.green = UInt8(length)
                }else{
                    pixel.green = pixel.green
                }

                myRGBA.pixels[index] = pixel
//                print("after")
//                print(myRGBA.pixels[index])
                
                counter += 1
            }
        }
        print("original_pixel")
        print(red_pixels[0..<24])
        stegoImage.image = myRGBA.toUIImage()
    }
    
    
    func retrieve_secret_message(){
        let stego_image = stegoImage.image
        let myRGBA = RGBAImage(image: stego_image!)!
        var red_pixel_array = [Int]()
        
        var counter = 0
        var message_length = 5;
        var no_of_bits_in_message = 5;
        for y in 0..<myRGBA.height {
            for x in 0..<(myRGBA.width){
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                if(counter == 0){
                    message_length = Int(pixel.green)
                    no_of_bits_in_message = Int(message_length) * 8
                    counter = 1
                }
                red_pixel_array.append(Int(pixel.red))
            }
        }
        
        var message_array = [Int]()
        for i in 0..<no_of_bits_in_message{
            var pixel_value = red_pixel_array[i]
            var pixel_binary_value = Int(get_binary(Int(pixel_value)))
            var lsb = pixel_binary_value! % 10
            message_array.append(Int(lsb))
        }
        
        var start_point = 0
        var final_point = 8
        var secret_message = ""
        for j in 0..<message_length{
           var character_binary = message_array[start_point..<final_point]
            var each_character_binary = Array(character_binary.reverse())
            let intValue = each_character_binary.reduce(0, combine: {$0*10 + $1})
            var actual_character = strtoul(String(intValue), nil, 2)
            start_point = final_point
            final_point += 8
            print("each ")
            print(each_character_binary)
            print(actual_character)
            var each_char = Character(UnicodeScalar(Int(actual_character)))
            secret_message += String(each_char)
        }
        print("message length ******")
        print(message_length)
        print(secret_message)
        
        retrievedMessageField.text = secret_message
        
        
    }
    
    func get_binary(number: Int) -> String{
        let b_number = String(number, radix: 2)
        let b_num = pad_zero(b_number, toSize: 8)
        
        return b_num
    }
    
    func put_ones_infront(number: Int) -> String{
        let f_num = pad_one(String(number), toSize: 8)
        return f_num
    }
    
    func pad_zero(string : String, toSize: Int) -> String {
        var padded = string
        for _ in 0..<(toSize - string.characters.count) {
            padded = "0" + padded
        }
        return padded
    }
    
    func pad_one(numb: String, toSize: Int) -> String {
        var padded = numb
        for _ in 0..<(toSize - numb.characters.count) {
            padded = "1" + padded
        }
        return padded
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let default_image = UIImage(named: "sample")!
        coverImage.image = default_image
    }
    
    override func viewWillAppear(animated: Bool) {
        self.coverImage.layer.borderWidth = 1
        self.view.backgroundColor = UIColor(red: 8/255, green: 80/255, blue: 80/255, alpha: 1)
        //
        navigationItem.title = "LSB Embedding"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}