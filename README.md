### README.md  

# **Sonkhya.AI: Handwritten Digit Recognition App**  
Sonkhya.AI is a Flutter-based application that utilizes a deep learning model to recognize handwritten **Bengali** digits with high accuracy. 

## **Features**  
- AI-based prediction using a TFLite CNN model.
- Interactive drawing board to input handwritten digits.
- Simple and clean UI for seamless interaction.  

## **How It Works**  
1. Draw a digit (0-9) on the provided whiteboard canvas in **Bengali**.  
2. Tap the **Predict** button.  
3. The app preprocesses the input by:  
   - Converting the image to grayscale.  
   - Resizing the image to 28x28 pixels.  
   - Normalizing pixel values.  
4. The processed image is passed to the TFLite model, which predicts the digit.  
5. The prediction result is displayed on the screen.  

## **Machine Learning Model**  
The deep learning model used for training the Bengali digit recognition system is available at:  
[**Bengali-Digit-Recognition**](https://github.com/SagnikBarik/Bengali-Digit-Recognition)  

## **Screenshots**  
<p>
<img src="screenshots/blackScreen.png" width="30%" style="padding-right:10px">
<img src="screenshots/cnnPrediction.png" width="30%" style="padding-right:10px">
<img src="screenshots/annPrediction.png" width="30%">
</p>
