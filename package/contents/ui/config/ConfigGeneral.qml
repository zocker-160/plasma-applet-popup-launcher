/*
 * Copyright 2016  Daniel Faust <hessijames@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    property alias cfg_title: title.text
    property alias cfg_icon: icon.text
    property var cfg_apps: []
    property alias cfg_widgetWidth: widgetWidth.value

    PlasmaCore.DataSource {
        id: appsSource
        engine: 'apps'
        connectedSources: sources
    }
    
    ColumnLayout {
        anchors.fill: parent

        GroupBox {
            title: i18n("Title")
            Layout.fillWidth: true

            TextField {
                id: title
                anchors.fill: parent
                horizontalAlignment: TextInput.AlignHCenter
            }
        }
        GroupBox {
            title: i18n("Icon")
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent

                TextField {
                    id: icon
                    Layout.fillWidth: true
                    horizontalAlignment: TextInput.AlignHCenter
                }

                Button {
                    iconName: "folder"
                    onClicked: iconDialog.open()
                }
            }

        }
        GroupBox {
            title: i18n("Widget width")
            Layout.fillWidth: true

            SpinBox {
                id: widgetWidth
                anchors.centerIn: parent

                minimumValue: units.iconSizes.medium + 2*units.smallSpacing
                maximumValue: 1000
                decimals: 0
                stepSize: 10
                suffix: ' px'
            }
        }
        GroupBox {
            title: i18n("Applications")
            Layout.fillWidth: true
            Layout.fillHeight: true

            Button {
                id: addAppButton
                //text: i18n('Add')
                //height: 30
                iconName: "list-add"
                onClicked: appSelector.open()
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right

                anchors.bottom: parent.bottom
                anchors.top: addAppButton.bottom
                anchors.topMargin: 10

                border {
                    width: 1
                    color: "lightgrey"
                }
                radius: 2
                color: "#20FFFFFF"

                ScrollView {
                    anchors.fill: parent

                    ListView {
                        id: apps
                        anchors.fill: parent
                        clip: true

                        delegate: Item {
                            id: appItem
                            width: parent.width
                            height: units.iconSizes.smallMedium + 2*units.smallSpacing

                            property bool isHovered: false
                            property bool isUpHovered: false
                            property bool isDownHovered: false
                            property bool isRemoveHovered: false

                            MouseArea {
                                id: container
                                anchors.fill: parent

                                hoverEnabled: true
                                onEntered: {
                                    apps.currentIndex = index
                                    isHovered = true
                                }
                                onExited: {
                                    isHovered = false
                                }

                                RowLayout {
                                    x: units.smallSpacing
                                    y: units.smallSpacing

                                    Item { // Hack - since setting the dimensions of PlasmaCore.IconItem won't work
                                        height: units.iconSizes.smallMedium
                                        width: height

                                        PlasmaCore.IconItem {
                                            anchors.fill: parent
                                            source: appsSource.data[modelData].iconName
                                            active: isHovered
                                        }
                                    }

                                    Label {
                                        text: appsSource.data[modelData].name
                                        height: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Rectangle {
                                    height: units.iconSizes.smallMedium
                                    width: 3*units.iconSizes.smallMedium + 4*units.smallSpacing
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: isHovered

                                    radius: units.iconSizes.smallMedium / 4
                                    color: theme.viewBackgroundColor
                                    opacity: 0.8

                                    Behavior on opacity { NumberAnimation { duration: units.shortDuration * 3 } }

                                    RowLayout {
                                        x: units.smallSpacing
                                        spacing: units.smallSpacing

                                        Item {
                                            id: upIcon
                                            height: units.iconSizes.smallMedium
                                            width: height
                                            opacity: 1.0

                                            PlasmaCore.IconItem {
                                                anchors.fill: parent
                                                source: 'arrow-up'
                                                active: isUpHovered

                                                MouseArea {
                                                    anchors.fill: parent

                                                    hoverEnabled: true
                                                    onEntered: {
                                                        isUpHovered = true
                                                    }
                                                    onExited: {
                                                        isUpHovered = false
                                                    }

                                                    onClicked: {
                                                        var m = moveUp(apps.model, modelData)
                                                        cfg_apps = m
                                                        apps.model = m
                                                    }
                                                }
                                            }
                                        }

                                        Item {
                                            id: downIcon
                                            height: units.iconSizes.smallMedium
                                            width: height
                                            opacity: 1.0

                                            PlasmaCore.IconItem {
                                                anchors.fill: parent
                                                source: 'arrow-down'
                                                active: isDownHovered

                                                MouseArea {
                                                    anchors.fill: parent

                                                    hoverEnabled: true
                                                    onEntered: {
                                                        isDownHovered = true
                                                    }
                                                    onExited: {
                                                        isDownHovered = false
                                                    }

                                                    onClicked: {
                                                        var m = moveDown(apps.model, modelData)
                                                        cfg_apps = m
                                                        apps.model = m
                                                    }
                                                }
                                            }
                                        }

                                        Item {
                                            id: removeIcon
                                            height: units.iconSizes.smallMedium
                                            width: height
                                            opacity: 1.0

                                            PlasmaCore.IconItem {
                                                anchors.fill: parent
                                                source: 'remove'
                                                active: isRemoveHovered

                                                MouseArea {
                                                    anchors.fill: parent

                                                    hoverEnabled: true
                                                    onEntered: {
                                                        isRemoveHovered = true
                                                    }
                                                    onExited: {
                                                        isRemoveHovered = false
                                                    }

                                                    onClicked: {
                                                        var m = apps.model
                                                        var i = null
                                                        while ((i = m.indexOf(modelData)) !== -1) {
                                                            m.splice(i, 1)
                                                        }
                                                        cfg_apps = m
                                                        apps.model = m
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Component.onCompleted: {
                            model = plasmoid.configuration.apps
                        }
                    }
                }
            }

        }
    }
    
    FileDialog {
        id: iconDialog
        title: 'Please choose an image file'
        folder: '/usr/share/icons/breeze/'
        nameFilters: ['Image files (*.png *.jpg *.xpm *.svg *.svgz)', 'All files (*)']
        onAccepted: {
            icon.text = iconDialog.fileUrl
        }
    }
    
    AppSelector {
        id: appSelector
        onAccepted: {
            console.log("accepted", selectedMenuId);

            const listModel = apps.model;
            listModel.push(selectedMenuId);

            cfg_apps = listModel;
            apps.model = listModel;
        }
    }

    function moveUp(m, value) {
        var index = m.indexOf(value)
        var newPos = index - 1

        if (newPos < 0)
            newPos = 0

        m.splice(index, 1)
        m.splice(newPos, 0, value)

        return m
    }

    function moveDown(m, value) {
        var index = m.indexOf(value)
        var newPos = index + 1

        if (newPos >= m.length)
            newPos = m.length

        m.splice(index, 1)
        m.splice(newPos, 0, value)

        return m
    }
}
