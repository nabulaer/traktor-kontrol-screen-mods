import CSI 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

import './../Definitions' as Definitions
import './../Widgets' as Widgets

//------------------------------------------------------------------------------------------------------------------
//  LIST ITEM - DEFINES THE INFORMATION CONTAINED IN ONE LIST ITEM
//------------------------------------------------------------------------------------------------------------------

// the model contains the following roles:
//  dataType, nodeIconId, nodeName, nrOfSubnodes, coverUrl, artistName, trackName, bpm, key, keyIndex, rating, loadedInDeck, prevPlayed, prelisten

Item {
  id: contactDelegate

  property int           screenFocus:           0
  property color         deckColor :            qmlBrowser.focusColor
  property color         textColor :            ListView.isCurrentItem ? deckColor : colors.colorFontsListBrowser
  property bool          isCurrentItem :        ListView.isCurrentItem
  property string        prepIconColorPostfix:  (screenFocus < 2 && ListView.isCurrentItem) ? "Blue" : ((screenFocus > 1 && ListView.isCurrentItem) ? "White" : "Grey")
  readonly property int  textTopMargin:         5 // centers text vertically
  readonly property bool isLoaded:              (model.dataType == BrowserDataType.Track) ? model.loadedInDeck.length > 0 : false
  // visible: !ListView.isCurrentItem

  height: 26
  anchors.left: parent.left
  anchors.right: parent.right

  // container for zebra & track infos
  Rectangle {
    // when changing colors here please remember to change it in the GridView in Templates/Browser.qml
    color:  (index%2 == 0) ? colors.colorGrey08 : "transparent"
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 1
    anchors.rightMargin: 1
    height: parent.height

    // track name, toggles with folder name
    Rectangle {
      id: firstFieldTrack
      anchors.left: parent.left //listImage.right
      anchors.top: parent.top
      anchors.topMargin: contactDelegate.textTopMargin
      anchors.leftMargin: 30
      width: 203
      visible: (model.dataType == BrowserDataType.Track)

      //! Dummy text to measure maximum text lenght dynamically and adjust icons behind it.
      Text {
        id: textLengthDummy
        visible: false
        font.pixelSize: fonts.smallFontSize
        text: (model.dataType == BrowserDataType.Track) ? model.trackName  : ( (model.dataType == BrowserDataType.Folder) ? model.nodeName : "")
      }

      Text {
        id: firstFieldText
        width: (textLengthDummy.width) > 200 ? 200 : textLengthDummy.width
        // visible: false
        elide: Text.ElideRight
        text: textLengthDummy.text
        font.pixelSize: fonts.smallFontSize
        color: getListItemTextColor()
      }

      Image {
        id: prepListIcon
        visible: (model.dataType == BrowserDataType.Track) ? model.prepared : false
        source: "./../Images/PrepListIcon" + prepIconColorPostfix + ".png"
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: firstFieldText.right
        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.leftMargin: 5
      }
    }

    // folder name
    Text {
      id: firstFieldFolder
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.topMargin: contactDelegate.textTopMargin
      anchors.leftMargin: 30
      color: textColor
      clip: true
      text: (model.dataType == BrowserDataType.Folder) ? model.nodeName : ""
      font.pixelSize: fonts.smallFontSize
      elide: Text.ElideRight
      visible: (model.dataType != BrowserDataType.Track)
    }


    // artist name
    Text {
      id: trackTitleField
      anchors.leftMargin: 7
      anchors.left: (model.dataType == BrowserDataType.Track) ? firstFieldTrack.right : firstFieldFolder.right
      anchors.top: parent.top
      anchors.topMargin: contactDelegate.textTopMargin
      width: 145
      color: getListItemTextColor()
      clip: true
      text: (model.dataType == BrowserDataType.Track) ? model.artistName: ""
      font.pixelSize: fonts.smallFontSize
      elide: Text.ElideRight
    }

    // bpm
    Text {
      id: bpmField
      anchors.left: trackTitleField.right
      anchors.top: parent.top
      anchors.topMargin: contactDelegate.textTopMargin
      horizontalAlignment: Text.AlignRight
      width: 30
      color: textColor
      clip: true
      text: (model.dataType == BrowserDataType.Track) ? model.bpm.toFixed(0) : ""
      font.pixelSize: fonts.smallFontSize
    }

    function colorForKey(keyIndex) {
      return colors.musicalKeyColors[keyIndex]
    }

    // key
    Text {
      id: keyField
      anchors.left: bpmField.right
      anchors.top: parent.top
      anchors.topMargin: contactDelegate.textTopMargin
      horizontalAlignment: Text.AlignRight

      color: (model.dataType == BrowserDataType.Track) ? (((model.key == "none") || (model.key == "None")) ? textColor : parent.colorForKey(model.keyIndex)) : textColor
      width: 30
      clip: true
      text: (model.dataType == BrowserDataType.Track) ? (((model.key == "none") || (model.key == "None")) ? "n.a." : model.key) : ""
      font.pixelSize: fonts.smallFontSize
    }

    ListHighlight {
      anchors.fill: parent
      visible: contactDelegate.isCurrentItem
      anchors.leftMargin: (model.dataType == BrowserDataType.Track) ? 27 : 0
      anchors.rightMargin: 0
    }
  }

  Rectangle {
    id: trackImage
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.leftMargin: 0
    width: 26
    height: 26
    color: (model.coverUrl != "") ? "transparent" : ((contactDelegate.screenFocus < 2) ? colors.colorDeckBlueBright50Full : colors.colorGrey128 )
    visible: (model.dataType == BrowserDataType.Track)

    Image {
      id: cover
      anchors.fill: parent
      source: (model.dataType == BrowserDataType.Track) ? ("image://covers/" + model.coverUrl ) : ""
      fillMode: Image.PreserveAspectFit
      clip: true
      cache: false
      sourceSize.width: width
      sourceSize.height: height
      // the image either provides the cover of the track, or if not available the traktor logo on colored background ( opacity == 0.3)
      opacity: (model.coverUrl != "") ? 1.0 : 0.3
    }

    // darkens unselected covers
    Rectangle {
      id: darkener
      anchors.fill: parent
      color: {
          if (model.prelisten)
          {
            return colors.browser.prelisten;
          }
          else
          {
            if (model.prevPlayed)
            {
              return colors.colorBlack88;
            }
            else
            {
              return "transparent";
            }
          }
        }
      }

    Rectangle {
      id: cover_border
      anchors.fill: trackImage
      color: "transparent"
      border.width: 1
      border.color: isCurrentItem ? colors.colorWhite16 : colors.colorGrey16 // semi-transparent border on artwork
      visible: (model.coverUrl != "")
    }

    Image {
      anchors.centerIn: trackImage
      width: 13
      height: 13
      source: "./../images/PreviewIcon_Big.png"
      fillMode: Image.Pad
      clip: true
      cache: false
      sourceSize.width: width
      sourceSize.height: height
      visible: (model.dataType == BrowserDataType.Track) ? model.prelisten : false
    }

    Image {
      anchors.centerIn: trackImage
      width: 13
      height: 13
      source: "./../images/PreviouslyPlayed_Icon.png"
      fillMode: Image.Pad
      clip: true
      cache: false
      sourceSize.width: width
      sourceSize.height: height
      visible: (model.dataType == BrowserDataType.Track) ? (model.prevPlayed && !model.prelisten) : false
    }

    Image {
      id: loadedDeckA
      source: "./../images/LoadedDeckA.png"
      anchors.top: parent.top
      anchors.left: parent.left
      sourceSize.width: 9
      sourceSize.height: 9
      visible: (model.dataType == BrowserDataType.Track && parent.isLoadedInDeck("A"))
    }

    Image {
      id: loadedDeckB
      source: "./../images/LoadedDeckB.png"
      anchors.top: parent.top
      anchors.right: parent.right
      sourceSize.width: 9
      sourceSize.height: 9
      visible: (model.dataType == BrowserDataType.Track && parent.isLoadedInDeck("B"))
    }

    Image {
      id: loadedDeckC
      source: "./../images/LoadedDeckC.png"
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      sourceSize.width: 9
      sourceSize.height: 9
      visible: (model.dataType == BrowserDataType.Track && parent.isLoadedInDeck("C"))
    }

    Image {
      id: loadedDeckD
      source: "./../images/LoadedDeckD.png"
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      sourceSize.width: 9
      sourceSize.height: 9
      visible: (model.dataType == BrowserDataType.Track && parent.isLoadedInDeck("D"))
    }

    function isLoadedInDeck(deckLetter)
    {
      return model.loadedInDeck.indexOf(deckLetter) != -1;
    }
  }

  // folder icon
  Image {
    id:       folderIcon
    source:   (model.dataType == BrowserDataType.Folder) ? ("image://icons/" + model.nodeIconId ) : ""
    width:    26
    height:   26
    fillMode: Image.PreserveAspectFit
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.leftMargin: 3
    clip:     true
    cache:    false
    visible:  false
  }

  ColorOverlay {
    id: folderIconColorOverlay
    color: isCurrentItem == false ? colors.colorFontsListBrowser : contactDelegate.deckColor // unselected vs. selected
    anchors.fill: folderIcon
    source: folderIcon
  }

  function hideCoverBorder() {
    if (model.dataType == BrowserDataType.Folder) {
      return false
    }
    return true
  }

  function getListItemKeyTextColor() {
    if (model.dataType != BrowserDataType.Track) {
      return textColor;
    }

    var keyOffset = utils.getMasterKeyOffset(qmlBrowser.getMasterKey(), model.key);
    if (keyOffset == 0) {
      return colors.color04MusicalKey; // Yellow
    }
    if (keyOffset == 1 || keyOffset == -1) {
      return colors.color02MusicalKey; // Orange
    }
    if (keyOffset == 2 || keyOffset == 7) {
      return colors.color07MusicalKey; // Green
    }
    if (keyOffset == -2 || keyOffset == -7) {
      return colors.color10MusicalKey; // Blue
    }

    return textColor;
  }

  function isLoadedInDeck(deckLetter)
  { return model.loadedInDeck.indexOf(deckLetter) != -1; }

  function getListItemTextColor() {
    if (model.dataType != BrowserDataType.Track) {
      return textColor;
    }
    if (model.prevPlayed && !model.prelisten) {
      return colors.colorGreen50Full;
    }
    if (isLoadedInDeck("A")) {
      return colors.colorWhite;
    }
    if (isLoadedInDeck("B")) {
      return colors.colorGreen;
    }
    return textColor;
  }
  }
