import QtQuick 1.1


Rectangle{
    id: root
    width: 1280
    height: 800
    color: "#000000"

    property int columns: 10
    property int rows: 6
    property int itemsPerPage: columns*rows
    property variant flow: GridView.TopToBottom

    GridView{
        id: grid
        width: 1000
        height: 600
        anchors.centerIn: parent
        model: 1000
        cellHeight: grid.height/rows
        cellWidth: grid.width/columns
        clip: true
        snapMode: GridView.SnapToRow
        flow: root.flow
        delegate: _testComponent


        Keys.onRightPressed: {
            if(flow === GridView.LeftToRight){
                if((currentIndex % columns !== columns - 1) && (currentIndex + 1 < count))
                    currentIndex++;
            }
            else{
                if(currentIndex + rows < grid.count && ((currentIndex + rows) % itemsPerPage) > (rows - 1))
                    currentIndex += rows;
            }
        }
        Keys.onLeftPressed: {
            if(flow === GridView.LeftToRight){
                if(currentIndex % columns !== 0)
                    currentIndex--;
            }
            else{
                if((currentIndex % itemsPerPage) >= rows)
                    currentIndex -= rows;
            }
        }
        Keys.onUpPressed: {
            if(flow === GridView.LeftToRight){
                if((currentIndex % itemsPerPage) >= columns)
                    currentIndex -= columns;
            }
            else{
                if(currentIndex % rows !== 0)
                    currentIndex--;
            }
        }
        Keys.onDownPressed: {
            if(flow === GridView.LeftToRight){
                if((currentIndex + columns < grid.count) && ((currentIndex + columns) % itemsPerPage) > (columns - 1))
                    currentIndex += columns;
            }
            else{
                if((currentIndex % rows !== rows - 1) && (currentIndex + 1 < count))
                    currentIndex++;
            }
        }

        onMovementEnded: {
            if(flow === GridView.LeftToRight){
                _centerPageAnimationVertical.restart();
                //get the new contentY after animation, then divide it by height to get the page num, then multiply it by the itemsPerPage
                grid.currentIndex = ((grid.height*Math.round(grid.contentY/grid.height))/grid.height)*itemsPerPage;
            }
            else{
                _centerPageAnimationHorizontal.restart();
                grid.currentIndex = ((grid.width*Math.round(grid.contentX/grid.width))/grid.width)*itemsPerPage;
            }
        }

        NumberAnimation { id: _centerPageAnimationVertical; target: grid; property: "contentY"; to: (grid.height*Math.round(grid.contentY/grid.height)); duration: 250 }
        NumberAnimation { id: _centerPageAnimationHorizontal; target: grid; property: "contentX"; to: (grid.width*Math.round(grid.contentX/grid.width)); duration: 250 }
        NumberAnimation { id: _pageDownAnimation; target: grid; property: "contentY"; to: grid.contentY + grid.height; duration: 250 }
        NumberAnimation { id: _pageRightAnimation; target: grid; property: "contentX"; to: grid.contentX + grid.width; duration: 250 }
        NumberAnimation { id: _pageUpAnimation; target: grid; property: "contentY"; to: grid.contentY - grid.height; duration: 250 }
        NumberAnimation { id: _pageLeftAnimation; target: grid; property: "contentX"; to: grid.contentX - grid.width; duration: 250 }

    }

    Rectangle{
        id: _pageUp
        color: "#FFFFFF"
        width: 100
        height: 50
        anchors.horizontalCenter: grid.horizontalCenter
        anchors.bottom: grid.top
        anchors.bottomMargin: 25

        visible: flow === Grid.LeftToRight && grid.currentIndex >= itemsPerPage

        Text{
            text: "Page Up"
            anchors.centerIn: parent
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(!grid.moving && !_centerPageAnimationVertical.running && grid.currentIndex >= itemsPerPage && !debounce.running){
                    _pageUpAnimation.restart();
                    debounce.restart();
                    grid.currentIndex = grid.currentIndex - itemsPerPage - (grid.currentIndex % itemsPerPage)
                }
            }
        }
    }

    Rectangle{
        id: _pageDown
        color: "#FFFFFF"
        width: 100
        height: 50
        anchors.horizontalCenter: grid.horizontalCenter
        anchors.top: grid.bottom
        anchors.topMargin: 25

        visible: flow === Grid.LeftToRight && (grid.currentIndex+itemsPerPage-(grid.currentIndex % itemsPerPage)) < grid.count

        Text{
            text: "Page Down"
            anchors.centerIn: parent
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(!grid.moving && !_centerPageAnimationVertical.running && (grid.currentIndex+itemsPerPage-(grid.currentIndex % itemsPerPage)) < grid.count && !debounce.running){
                    _pageDownAnimation.restart();
                    debounce.restart();
                    grid.currentIndex = grid.currentIndex + itemsPerPage - (grid.currentIndex % itemsPerPage)
                }
            }
        }
    }

    Rectangle{
        id: _pageLeft
        color: "#FFFFFF"
        width: 100
        height: 50
        anchors.right: grid.left
        anchors.verticalCenter: grid.verticalCenter
        anchors.rightMargin: 25

        visible: flow === Grid.TopToBottom && grid.currentIndex >= itemsPerPage

        Text{
            text: "Page Left"
            anchors.centerIn: parent
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(!grid.moving && !_centerPageAnimationHorizontal.running && grid.currentIndex >= itemsPerPage && !debounce.running){
                    _pageLeftAnimation.restart();
                    debounce.restart();
                    grid.currentIndex = grid.currentIndex - itemsPerPage - (grid.currentIndex % itemsPerPage)
                }
            }
        }
    }

    Rectangle{
        id: _pageRight
        color: "#FFFFFF"
        width: 100
        height: 50
        anchors.left: grid.right
        anchors.verticalCenter: grid.verticalCenter
        anchors.leftMargin: 25

        visible: flow === Grid.TopToBottom && (grid.currentIndex+itemsPerPage-(grid.currentIndex % itemsPerPage)) < grid.count

        Text{
            text: "Page Right"
            anchors.centerIn: parent
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(!grid.moving && !_centerPageAnimationHorizontal.running && (grid.currentIndex+itemsPerPage-(grid.currentIndex % itemsPerPage)) < grid.count && !debounce.running){
                    _pageRightAnimation.restart();
                    debounce.restart();
                    grid.currentIndex = grid.currentIndex + itemsPerPage - (grid.currentIndex % itemsPerPage)
                }
            }
        }
    }

    Component{
        id: _testComponent
        Item{
            id: _item
            width: grid.cellWidth
            height: grid.cellHeight


            Rectangle{
                id: _highlight
                width: _item.width
                height: _item.height
                color: "lightblue"
                visible: grid.currentIndex === index
            }

            Rectangle{
                id: _rect
                width: grid.cellWidth - 5
                height: grid.cellHeight - 5
                color: "green"
                anchors.centerIn: _item

                Text{
                    anchors.centerIn: parent
                    color: "#FFFFFF"
                    text: index
                }
            }
            MouseArea{
                anchors.fill: _item
                onClicked: {
                    grid.forceActiveFocus();
                    grid.currentIndex = index;
                }
            }
        }
    }

    Timer{
        id: debounce
        running: false; repeat: false; interval: 300
    }
}
