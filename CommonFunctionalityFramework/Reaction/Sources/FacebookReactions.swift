/*
 * Reactions
 *
 * Copyright 2016-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit

/// Default implementation of the facebook reactions.
extension Reaction {
  /// Struct which defines the standard facebook reactions.
  public struct facebook {
    /// The facebook's "like" reaction.
    public static var like: Reaction {
      return reactionWithId("Like")
    }

    /// The facebook's "love" reaction.
    public static var love: Reaction {
      return reactionWithId("Love")
    }

    /// The facebook's "haha" reaction.
    public static var haha: Reaction {
      return reactionWithId("Clap")
    }

    /// The facebook's "wow" reaction.
    public static var wow: Reaction {
      return reactionWithId("Celebrate")
    }

    /// The facebook's "sad" reaction.
    public static var sad: Reaction {
      return reactionWithId("Support")
    }

    /// The facebook's "angry" reaction.
    public static var angry: Reaction {
      return reactionWithId("angry")
    }

    /// The list of standard facebook reactions in this order: `.like`, `.love`, `.haha`, `.wow`, `.sad`, `.angry`.
    //public static let all: [Reaction] = [facebook.like, facebook.love, facebook.haha, facebook.sad, facebook.wow ]
      public static let all: [Reaction] = {
          var reactions: [Reaction] = []
          
          // Add reactions based on user defaults
          if UserDefaults.standard.bool(forKey: "like") {
              reactions.append(facebook.like)
          }
          
          if UserDefaults.standard.bool(forKey: "love") {
              reactions.append(facebook.love)
          }
          
          if UserDefaults.standard.bool(forKey: "clap") {
              reactions.append(facebook.haha)
          }
          
          if UserDefaults.standard.bool(forKey: "support") {
              reactions.append(facebook.sad)
          }
          
          if UserDefaults.standard.bool(forKey: "celebrate") {
              reactions.append(facebook.wow)
          }
          
          return reactions
      }()

    // MARK: - Convenience Methods

    private static func reactionWithId(_ id: String) -> Reaction {
      var color: UIColor            = .black
      var alternativeIcon: UIImage? = nil

      switch id {
      case "Like":
        color           = #colorLiteral(red: 0.1263153851, green: 0.1618461013, blue: 0.4399832487, alpha: 1)
        //alternativeIcon = imageWithName("GrayLike").withRenderingMode(.alwaysTemplate)
      case "Love":
          color = #colorLiteral(red: 1, green: 0, blue: 0.3095907271, alpha: 1)
      case "Clap":
          color = #colorLiteral(red: 0.2509803922, green: 0.7960784314, blue: 0.3411764706, alpha: 1)
      case "Support":
          color = #colorLiteral(red: 0.2039215686, green: 0.6666666667, blue: 0.862745098, alpha: 1)
      case "Celebrate":
          color = #colorLiteral(red: 0.1830490232, green: 0.5008765459, blue: 0.9294117647, alpha: 1)
      default:
        color = UIColor(red: 0.99, green: 0.84, blue: 0.38, alpha: 1)
      }

      return Reaction(id: id, title: id.localized(from: "FacebookReactionLocalizable"), color: color, icon: imageWithName(id), alternativeIcon: alternativeIcon)
    }

    private static func imageWithName(_ name: String) -> UIImage {
        if let image = UIImage(named: name, in: .reactionsBundle(), compatibleWith: nil) {
            return image
        }
        return UIImage()
      }
  }
}
