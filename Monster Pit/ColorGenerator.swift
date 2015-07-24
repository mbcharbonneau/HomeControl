//
//  ColorGenerator.swift
//  Color Generator
//
//  Created by mbcharbonneau on 1/6/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation
import UIKit

class ColorGenerator: NSObject {

    private let goldenRatioConjugate: Float
    private let gradientDistance: Float
    private var randomHue: Float

    var saturation: Float
    var brightness: Float

    override init() {

        srand48( time( nil ) );

        goldenRatioConjugate = ( sqrt( 5.0 ) - 1.0 ) / 2.0
        gradientDistance = 0.3
        randomHue = Float( drand48() )
        saturation = 0.5
        brightness = 0.95
    }

    // Returns a new random color. Each call will yeild a color that is visually
    // distinct from the previous random color.

    func randomColor() -> UIColor {

        randomHue += goldenRatioConjugate
        randomHue %= 1.0

        return UIColor( hue: CGFloat( randomHue ), saturation: CGFloat( saturation ), brightness: CGFloat( brightness ), alpha: 1.0 )
    }

    // Returns a pair of random colors suitable for a nice gradient.

    func gradientColors() -> ( start:UIColor, end:UIColor ) {

        let startHue: Float = Float( drand48() ) % 1.0
        let endHue: Float = ( startHue + gradientDistance ) % 1.0

        let start = UIColor( hue: CGFloat( startHue ), saturation: CGFloat( saturation ), brightness: CGFloat( brightness ), alpha: 1.0 )
        let end = UIColor( hue: CGFloat( endHue ), saturation: CGFloat( saturation ), brightness: CGFloat( brightness ), alpha: 1.0 )

        return ( start, end )
    }

    // Create a random variant of the given baseColor, using distance to
    // determine how much to change the RGB values.

    func varyColor( baseColor:UIColor, distance:CGFloat ) -> UIColor {

        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0

        baseColor.getRed( &red, green: &green, blue: &blue, alpha: nil )

        var randomRed: CGFloat = CGFloat( drand48() ) % distance
        var randomGreen: CGFloat = CGFloat( drand48() ) % distance
        var randomBlue: CGFloat = CGFloat( drand48() ) % distance

        red += ( red + randomRed > 1.0 ) ? randomRed * -1.0 : randomRed
        green += ( red + randomGreen > 1.0 ) ? randomGreen * -1.0 : randomGreen
        blue += ( red + randomBlue > 1.0 ) ? randomBlue * -1.0 : randomBlue

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

}
