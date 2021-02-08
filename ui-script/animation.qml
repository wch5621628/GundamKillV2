/********************************************************************
    Copyright (c) 2013-2014 - QSanguosha-Rara

    This file is part of QSanguosha-Hegemony.

    This game is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 3.0
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    See the LICENSE file for more details.

    QSanguosha-Rara
    *********************************************************************/

import QtQuick 1.0

Rectangle {
    id: container

    signal animationCompleted()

    Rectangle {
        id: mask
        x: 0
        width: sceneWidth
        height: sceneHeight
        color: "black"
        opacity: 0
        z: 990
    }

	/*
    Rectangle {
        id: flicker_mask
        x: 0
        width: sceneWidth
        height: sceneHeight
        color: "white"
        visible: false
        z: 1000
		opacity: 0.5
    }
	*/
	
	Image {
		id: flicker_mask
        x: 0
        width: sceneWidth
        height: sceneHeight
		visible: false
		fillMode: Image.PreserveAspectCrop
		source: "../image/animate/flicker_mask.jpg"
		z: 990.5
		
		MouseArea {
			id: mask_click
			enabled: false
			anchors.fill: parent
			onClicked: {
				container.animationCompleted()
			}
		}
	}

    Image {
        id: heroPic
        x: -1000
        y: sceneHeight / 2 - 350
        fillMode: Image.PreserveAspectFit
        source: "../image/animate/" + hero + ".png"
        scale: 0.3
        z: 991
    }

	FontLoader { id: fixedFont; source: "../font/NZBZ.ttf" }

    Text {
        id: text
        color: "white"
        text: skill
        font.family: fixedFont.name//"LiSu"
        style: Text.Outline
        font.pointSize: 900
        opacity: 0
        z: 999
        x: sceneWidth / 2
        y: sceneHeight / 2
    }

	//skill animation
    ParallelAnimation {
        id: step1
        running: true
        PropertyAnimation {
            target: heroPic
            property: "x"
            to: tableWidth / 2 - 500
            duration: 600
            easing.type: Easing.OutQuad
        }
        PropertyAnimation{
            target: mask
            property: "opacity"
            to: 0.7
            duration: 880
        }
        onCompleted: {
            heroPic.visible = false
            flicker_mask.visible = true
            pause1.start()
        }
    }
    PauseAnimation {
        id: pause1
        duration: 20
        onCompleted: {
            flicker_mask.visible = false
            pause2.start()
        }
    }
    PauseAnimation {
        id: pause2
        duration: 80
        onCompleted: {
            flicker_mask.visible = true
            pause3.start()
        }
    }
    PauseAnimation {
        id: pause3
        duration: 20
        onCompleted: {
            //flicker_mask.visible = false
            heroPic.visible = true
            step2.start()
        }
    }
    SequentialAnimation {
        id: step2
        onCompleted: {
            container.visible = false
            container.animationCompleted()
        }

        PropertyAnimation {
            id: zoom_in
            target: heroPic
            easing.overshoot: 6.252
            easing.type: Easing.OutBack
            property: "scale"
            to: 1.0
            duration: 800
        }
        ParallelAnimation {
            PropertyAnimation {
                target: text
                property: "opacity"
                to: 1.0
                duration: 800
            }
            PropertyAnimation {
                target: text
                property: "font.pointSize"
                to: 90
                duration: 800
            }
        }
        PauseAnimation { duration: 1700 }
    }
	//skill animation end
	
	//ssr animation
	//感谢Notify大神
	Image {
		id: heroCard
        opacity: 0
		rotation: 10
		height: 292
        scale: 1.5
        x: tableWidth / 2
        y: sceneHeight / 2 - 160
		z: 992
	}
	
	Image {
		property int currentImage: 0
		id: heroCardBg
		rotation: 10
		width: 412
		source: "../image/animate/mvp" + currentImage + ".png"
		x: heroCard.x - 121
        y: heroCard.y - 90
		scale: 1.5
		z: 991
		visible: false
		NumberAnimation on currentImage {
			from: 0
			to: 7
			loops: Animation.Infinite
			duration: 800
        }
	}

	Image {
		id: ssrText //mvpText
		source: "../image/animate/ssr.png" //mvp.png"
		scale: 1.6
        opacity: 0
        x: sceneWidth / 2 - 460
        y: sceneHeight / 2 - 260
		z: 1000
	}

	Image {
		id: ssrNew
		source: "../image/animate/ssrNew.png"
        opacity: 0
        x: tableWidth / 2 + 400
        y: sceneHeight / 8
		z: 1000
		visible: false
	}

    ParallelAnimation {
        id: ssrstep1 //mvpstep1
        running: false
		PropertyAnimation {
			target: heroCard
			property: "x"
			to: tableWidth / 2 + 400
			duration: 400
			easing.type: Easing.OutQuad
			easing.overshoot: 3
		}
		PropertyAnimation {
			target: heroCard
			property: "opacity"
			to: 1
			duration: 400
		}
        PropertyAnimation {
            target: ssrText //mvpText
            property: "opacity"
            to: 1
            duration: 400
        }
		PropertyAnimation {
            target: ssrNew
            property: "opacity"
            to: 1
            duration: 400
        }
        /*PropertyAnimation{
            target: mask
            property: "opacity"
            to: 0.7
            duration: 880
        }*/
        onCompleted: {
			text.x = text.x - 150
			text.y = text.y + 150
            ssrstep2.start() //mvpstep2.start()
			heroCardBg.visible = true
        }
    }

    SequentialAnimation {
        id: ssrstep2 //mvpstep2
        onCompleted: {
            container.visible = false
            container.animationCompleted()
        }

        ParallelAnimation {
			
            PropertyAnimation {
                target: text
                property: "opacity"
                to: 1.0
                duration: 500
            }
            PropertyAnimation {
                target: text
                property: "font.pointSize"
                to: 90
                duration: 500
            }
        }

        PauseAnimation { duration: 2000 } //3000

    }

	//ten draws animation
	Image {
		id: draw1
		visible: false
        x: (sceneWidth - 1400 * 0.7) / 2
        y: (sceneHeight - 680 * 0.7) /2
		z: 1000
		rotation: 10
		scale: 0
	}
	
	Image {
		id: draw2
		visible: false
        x: draw1.x + 300 * 0.7
        y: draw1.y
		z: 1000
		rotation: 10
		scale: 0
	}
	
	Image {
		id: draw3
		visible: false
        x: draw2.x + 300 * 0.7
        y: draw1.y
		z: 1000
		rotation: 10
		scale: 0
	}
	
	Image {
		id: draw4
		visible: false
        x: draw3.x + 300 * 0.7
        y: draw1.y
		z: 1000
		rotation: 10
		scale: 0
	}
	
	Image {
		id: draw5
		visible: false
        x: draw4.x + 300 * 0.7
        y: draw1.y
		z: 1000
		rotation: 10
		scale: 0
	}
	
	Image {
		id: draw6
		visible: false
        x: draw1.x
        y: draw1.y + 400 * 0.7
		z: 1000
		rotation: 10
		scale: 0
	}
	
	Image {
		id: draw7
		visible: false
        x: draw6.x + 300 * 0.7
        y: draw1.y + 400 * 0.7
		z: 1000
		rotation: 10
		scale: 0
	}
	
	Image {
		id: draw8
		visible: false
        x: draw7.x + 300 * 0.7
        y: draw1.y + 400 * 0.7
		z: 1000
		rotation: 10
		scale: 0
	}
	
	Image {
		id: draw9
		visible: false
        x: draw8.x + 300 * 0.7
        y: draw1.y + 400 * 0.7
		z: 1000
		rotation: 10
		scale: 0
	}
	
	Image {
		id: draw10
		visible: false
        x: draw9.x + 300 * 0.7
        y: draw1.y + 400 * 0.7
		z: 1000
		rotation: 10
		scale: 0
	}

	Image {
		id: new1
		source: "../image/animate/ssrNew.png"
		visible: false
		x: draw1.x
		y: draw1.y
		z: 1100
		scale: 0.5
	}
	
	Image {
		id: new2
		source: "../image/animate/ssrNew.png"
		visible: false
		x: draw2.x
		y: draw2.y
		z: 1100
		scale: 0.5
	}
	
	Image {
		id: new3
		source: "../image/animate/ssrNew.png"
		visible: false
		x: draw3.x
		y: draw3.y
		z: 1100
		scale: 0.5
	}
	
	Image {
		id: new4
		source: "../image/animate/ssrNew.png"
		visible: false
		x: draw4.x
		y: draw4.y
		z: 1100
		scale: 0.5
	}
	
	Image {
		id: new5
		source: "../image/animate/ssrNew.png"
		visible: false
		x: draw5.x
		y: draw5.y
		z: 1100
		scale: 0.5
	}
	
	Image {
		id: new6
		source: "../image/animate/ssrNew.png"
		visible: false
		x: draw6.x
		y: draw6.y
		z: 1100
		scale: 0.5
	}
	
	Image {
		id: new7
		source: "../image/animate/ssrNew.png"
		visible: false
		x: draw7.x
		y: draw7.y
		z: 1100
		scale: 0.5
	}
	
	Image {
		id: new8
		source: "../image/animate/ssrNew.png"
		visible: false
		x: draw8.x
		y: draw8.y
		z: 1100
		scale: 0.5
	}
	
	Image {
		id: new9
		source: "../image/animate/ssrNew.png"
		visible: false
		x: draw9.x
		y: draw9.y
		z: 1100
		scale: 0.5
	}
	
	Image {
		id: new10
		source: "../image/animate/ssrNew.png"
		visible: false
		x: draw10.x
		y: draw10.y
		z: 1100
		scale: 0.5
	}

	Text {
		id: ten_draws_text
		color: "white"
		text: "十连结果"
		font.family: fixedFont.name
		style: Text.Outline
		font.pointSize: 50
		font.underline: true
		z: 1200
		x: sceneWidth / 2 - 100
		y: draw1.y - 125 * 0.7
		visible: false
    }

	Text {
		id: ten_draws_tips
		color: "white"
		text: "<点击任意处返回>"
		font.family: fixedFont.name
		style: Text.Outline
		font.pointSize: 20
		z: 1200
		x: sceneWidth / 2 - 90
		y: sceneHeight - 125 * 0.7
		visible: false
    }

	Text {
		id: counter
		property int value: 0
		color: "white"
		text: (value % 60).toString()
		font.family: fixedFont.name
		style: Text.Outline
		font.pointSize: 50
		x: sceneWidth - 100
		y: sceneHeight - 100
		z: 1200
		visible: false
	}

	NumberAnimation {
		id: counterAnim

		function begin(n) {
			from = n
			duration = n * 1000
			start()
		}

		target: counter
		property: "value"
		to: 0
	}

	SequentialAnimation {
        id: ten_draws
		running: false
        onCompleted: {
            container.visible = false
            container.animationCompleted()
        }

        ParallelAnimation {
			ScriptAction {
				script: {
					ten_draws_text.visible = true
					ten_draws_tips.visible = true
				}					
			}
			
            PropertyAnimation {
                target: draw1
                property: "scale"
                to: 0.7
                duration: 200
            }
			PropertyAnimation {
                target: draw2
                property: "scale"
                to: 0.7
                duration: 200
            }
			PropertyAnimation {
                target: draw3
                property: "scale"
                to: 0.7
                duration: 200
            }
			PropertyAnimation {
                target: draw4
                property: "scale"
                to: 0.7
                duration: 200
            }
			PropertyAnimation {
                target: draw5
                property: "scale"
                to: 0.7
                duration: 200
            }
			PropertyAnimation {
                target: draw6
                property: "scale"
                to: 0.7
                duration: 200
            }
			PropertyAnimation {
                target: draw7
                property: "scale"
                to: 0.7
                duration: 200
            }
			PropertyAnimation {
                target: draw8
                property: "scale"
                to: 0.7
                duration: 200
            }
			PropertyAnimation {
                target: draw9
                property: "scale"
                to: 0.7
                duration: 200
            }
			PropertyAnimation {
                target: draw10
                property: "scale"
                to: 0.7
                duration: 200
            }
        }

		ScriptAction {
			script: {
				counterAnim.begin(5)
				counter.visible = true
			}					
		}

        PauseAnimation { duration: 5000 }

    }

	//TRANS-AM animation
	Image {
		property int currentImage: 0
		id: transamImg
		source: "../image/animate/TRANS-AM/" + currentImage + ".jpg"
		x: 0
		width: sceneWidth
		height: sceneHeight
		z: 990.5
		visible: false
		fillMode: Image.PreserveAspectCrop
		opacity: 0
		NumberAnimation on currentImage {
			from: 0
			to: 8
			duration: 1000
        }
	}

	SequentialAnimation {
        id: transam
		running: false
        onCompleted: {
            container.visible = false
            container.animationCompleted()
        }

		ParallelAnimation {
			ScriptAction {
				script: {
					transamImg.visible = true
				}					
			}
			
			PropertyAnimation {
				target: transamImg
				property: "opacity"
				to: 0.9
				duration: 200
			}
		}
		
		PauseAnimation { duration: 1500 }

    }

	Component.onCompleted: {
		var arr = hero.split(":")
		if (arr.length == 1) {
			flicker_mask.opacity = 0.5
			step1.running = true
        } else if (arr[0] == "ssr") {
            flicker_mask.source = "../image/animate/ssrBg.jpg"
			pause1.duration = 0
			pause2.duration = 0
			heroCard.source = "../image/generals/card/" + arr[1] + ".jpg"
			if (arr[2] == "new") {
				ssrNew.visible = true
			}
			//mask_click.enabled = true
            ssrstep1.running = true
		} else if (arr[0] == "ten_draws") {
			var names = arr[1].split("+")
			var news = arr[2].split("+")
			var path = "../image/generals/card/"
			
			draw1.source = path + names[0] + ".jpg"
			draw1.visible = true
			draw2.source = path + names[1] + ".jpg"
			draw2.visible = true
			draw3.source = path + names[2] + ".jpg"
			draw3.visible = true
			draw4.source = path + names[3] + ".jpg"
			draw4.visible = true
			draw5.source = path + names[4] + ".jpg"
			draw5.visible = true
			draw6.source = path + names[5] + ".jpg"
			draw6.visible = true
			draw7.source = path + names[6] + ".jpg"
			draw7.visible = true
			draw8.source = path + names[7] + ".jpg"
			draw8.visible = true
			draw9.source = path + names[8] + ".jpg"
			draw9.visible = true
			draw10.source = path + names[9] + ".jpg"
			draw10.visible = true
			
			new1.visible = Number(news[0])
			new2.visible = Number(news[1])
			new3.visible = Number(news[2])
			new4.visible = Number(news[3])
			new5.visible = Number(news[4])
			new6.visible = Number(news[5])
			new7.visible = Number(news[6])
			new8.visible = Number(news[7])
			new9.visible = Number(news[8])
			new10.visible = Number(news[9])
			
			flicker_mask.source = ""
			pause1.duration = 0
			pause2.duration = 0
			mask_click.enabled = true
			ten_draws.running = true
		} else if (arr[0] == "TRANS-AM") {
			flicker_mask.source = ""
			flicker_mask.opacity = 0
			pause1.duration = 0
			pause2.duration = 0
			transam.running = true
		}
	}
}

