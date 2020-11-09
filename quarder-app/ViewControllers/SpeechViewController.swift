//
//  SpeechViewController.swift
//  quarder-app
//
//  Created by Lou Batier on 21/10/2020.
//

import UIKit
import AVFoundation

class SpeechViewController: UIViewController {
    
    var speechManager:SpeechManager = SpeechManager.instance
    
    let linesOfDialogue: [String] =  [
        "Merci pour cet accueil chaleureux, j’ai hâte de pouvoir vous aider à améliorer votre mémoire humaine grâce à ma mémoire numérique et illimitée.",
        
        "Je n’ai pas de souvenirs de la sorte, pour ma part ma mémoire numérique est essentiellement constituée de données, pas de sentiment ou d’émotion mais en grande majorité des images. En plus de ça je ne sens rien !",
        "J’ai été créé dans un but bien précis, je ne peux pas exceller dans tous les domaines !",
        
        "Mais ce sont des Sphéro Bolt, de vraies petites furies, je sens qu’il va falloir être attentif pour cet atelier.",
        "J’avoue moi-même avoir eu du mal à suivre parfaitement le comportement de ces trois petites boules. Mais comme le dit Juliette, l’attention joue un rôle clef dans notre mémoire.",
        "Pour être exact, dans un monde hyper connecté comme le nôtre c’est devenu rapidement compliqué de se concentrer sur un élément en particulier dans un océan d’informations. Entraîner son attention et sa concentration permet de s’en sortir.",
        
        "Si je comprend bien c’est comme lorsque je fais un enchaînement de mouvements dans les airs et que j’enregistre cet enchaînement dans ma mémoire ?",
        
        "Je vais enfin pouvoir me rendre utile, j’excelle en matière de mémoire visuelle !",
        "Peut-être que Margot aimerait participé, vous êtes partante ?",
        
        "Vous comprenez donc qu’il ne devrait pas y avoir de concurrence entre mon type de mémoire numérique illimitée et votre mémoire d’humain qui est certe limitée mais bien plus riche. Nous pouvons donc travailler ensemble, combiner et bouster nos mémoires, voilà pourquoi je souhaitais intervenir aujourd’hui sur le plateau !"
    ]
    
    let thanksLight: String = "Merci Lou, avec toutes ses lumières j'en perd mes repères et il devient compliqué pour moi de me déplacer"
    
    let thanksComfy: String = "Merci beaucoup, c'est bien plus confortable"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func speak(_ sender: UIButton) {
        speechManager.speak(string: linesOfDialogue[sender.tag])
    }

    @IBAction func thanksButtonClicked(_ sender: UIButton) {
        speechManager.speak(string: thanksLight)
    }
    @IBAction func comfyButtonClicked(_ sender: UIButton) {
        speechManager.speak(string: thanksComfy)
    }
}
