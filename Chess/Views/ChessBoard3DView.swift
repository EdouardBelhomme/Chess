import SceneKit
import SwiftUI

struct ChessBoard3DView: UIViewRepresentable {
    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = context.coordinator.scene
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        context.coordinator.updateBoard(viewModel: viewModel, theme: appearanceManager.currentTheme)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, theme: appearanceManager.currentTheme)
    }

    class Coordinator: NSObject {
        var viewModel: GameViewModel
        var theme: BoardTheme
        let scene: SCNScene
        var pieceNodes: [String: SCNNode] = [:]
        var tileNodes: [[SCNNode]] = []
        var moveIndicatorNodes: [SCNNode] = []
        var selectionHighlightNode: SCNNode?

        init(viewModel: GameViewModel, theme: BoardTheme) {
            self.viewModel = viewModel
            self.theme = theme
            self.scene = SCNScene()
            super.init()
            setupScene()
            setupBoard()
            updatePieces()
        }

        private func setupScene() {
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.usesOrthographicProjection = true
            cameraNode.camera?.orthographicScale = 4.5
            cameraNode.position = SCNVector3(x: 3.5, y: 7, z: 9)
            cameraNode.look(at: SCNVector3(x: 3.5, y: 0.3, z: 3.5))
            scene.rootNode.addChildNode(cameraNode)

            let ambientLight = SCNNode()
            ambientLight.light = SCNLight()
            ambientLight.light?.type = .ambient
            ambientLight.light?.intensity = 400
            ambientLight.light?.color = UIColor(white: 0.9, alpha: 1)
            scene.rootNode.addChildNode(ambientLight)

            let sunLight = SCNNode()
            sunLight.light = SCNLight()
            sunLight.light?.type = .directional
            sunLight.light?.intensity = 600
            sunLight.light?.color = UIColor.white
            sunLight.light?.castsShadow = true
            sunLight.light?.shadowMode = .deferred
            sunLight.light?.shadowSampleCount = 8
            sunLight.light?.shadowRadius = 2
            sunLight.light?.shadowColor = UIColor.black.withAlphaComponent(0.35)
            sunLight.position = SCNVector3(x: 5, y: 10, z: 7)
            sunLight.look(at: SCNVector3(x: 3.5, y: 0, z: 3.5))
            scene.rootNode.addChildNode(sunLight)

            let fillLight = SCNNode()
            fillLight.light = SCNLight()
            fillLight.light?.type = .directional
            fillLight.light?.intensity = 300
            fillLight.light?.color = UIColor(white: 0.95, alpha: 1)
            fillLight.position = SCNVector3(x: 3.5, y: 5, z: 12)
            fillLight.look(at: SCNVector3(x: 3.5, y: 0.5, z: 3.5))
            scene.rootNode.addChildNode(fillLight)
        }

        private func setupBoard() {
            let tileSize: CGFloat = 1.0
            let tileHeight: CGFloat = 0.15

            for row in 0..<8 {
                var rowNodes: [SCNNode] = []
                for col in 0..<8 {
                    let tileGeometry = SCNBox(
                        width: tileSize, height: tileHeight, length: tileSize, chamferRadius: 0.02)
                    let isLight = (row + col) % 2 == 0
                    let material = SCNMaterial()
                    material.diffuse.contents =
                        isLight ? UIColor(theme.lightSquareColor) : UIColor(theme.darkSquareColor)
                    material.lightingModel = .blinn
                    material.roughness.contents = 0.7
                    material.specular.contents = UIColor(white: 0.2, alpha: 1)
                    tileGeometry.materials = [material]

                    let tileNode = SCNNode(geometry: tileGeometry)
                    tileNode.position = SCNVector3(
                        x: Float(col),
                        y: Float(tileHeight / 2),
                        z: Float(row)
                    )
                    tileNode.name = "tile_\(row)_\(col)"
                    scene.rootNode.addChildNode(tileNode)
                    rowNodes.append(tileNode)
                }
                tileNodes.append(rowNodes)
            }

            let baseGeometry = SCNBox(width: 8.4, height: 0.2, length: 8.4, chamferRadius: 0.1)
            let baseMaterial = SCNMaterial()
            baseMaterial.diffuse.contents = UIColor(theme.borderColor)
            baseMaterial.lightingModel = .physicallyBased
            baseMaterial.roughness.contents = 0.5
            baseGeometry.materials = [baseMaterial]

            let baseNode = SCNNode(geometry: baseGeometry)
            baseNode.position = SCNVector3(x: 3.5, y: -0.1, z: 3.5)
            scene.rootNode.addChildNode(baseNode)
        }

        func updateBoard(viewModel: GameViewModel, theme: BoardTheme) {
            self.viewModel = viewModel

            if self.theme != theme {
                self.theme = theme
                for row in 0..<8 {
                    for col in 0..<8 {
                        let isLight = (row + col) % 2 == 0
                        if let material = tileNodes[row][col].geometry?.firstMaterial {
                            material.diffuse.contents =
                                isLight
                                ? UIColor(theme.lightSquareColor) : UIColor(theme.darkSquareColor)
                        }
                    }
                }
            }

            updatePieces()
            updateMoveIndicators()
        }

        private func updateMoveIndicators() {
            for node in moveIndicatorNodes {
                node.removeFromParentNode()
            }
            moveIndicatorNodes.removeAll()

            selectionHighlightNode?.removeFromParentNode()
            selectionHighlightNode = nil

            if let selectedPos = viewModel.selectedPosition {
                let highlight = SCNCylinder(radius: 0.45, height: 0.02)
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.green.withAlphaComponent(0.5)
                material.emission.contents = UIColor.green.withAlphaComponent(0.3)
                highlight.materials = [material]

                let highlightNode = SCNNode(geometry: highlight)
                highlightNode.position = SCNVector3(
                    x: Float(selectedPos.col),
                    y: 0.12,
                    z: Float(selectedPos.row)
                )
                scene.rootNode.addChildNode(highlightNode)
                selectionHighlightNode = highlightNode
            }

            for move in viewModel.validMovesForSelection {
                let targetPos = move.end
                let isCapture = viewModel.chessEngine.board[targetPos] != nil

                let indicator: SCNGeometry
                if isCapture {
                    indicator = SCNTorus(ringRadius: 0.35, pipeRadius: 0.05)
                } else {
                    indicator = SCNSphere(radius: 0.12)
                }

                let material = SCNMaterial()
                material.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.7)
                material.emission.contents = UIColor.systemBlue.withAlphaComponent(0.3)
                indicator.materials = [material]

                let indicatorNode = SCNNode(geometry: indicator)
                indicatorNode.name = "tile_\(targetPos.row)_\(targetPos.col)"
                indicatorNode.position = SCNVector3(
                    x: Float(targetPos.col),
                    y: 0.15,
                    z: Float(targetPos.row)
                )
                scene.rootNode.addChildNode(indicatorNode)
                moveIndicatorNodes.append(indicatorNode)
            }
        }

        private func updatePieces() {
            for (_, node) in pieceNodes {
                node.removeFromParentNode()
            }
            pieceNodes.removeAll()

            for row in 0..<8 {
                for col in 0..<8 {
                    let position = Position(row: row, col: col)
                    if let piece = viewModel.chessEngine.board[position] {
                        let pieceNode = createPieceNode(piece: piece, at: position)
                        scene.rootNode.addChildNode(pieceNode)
                        pieceNodes["\(row)_\(col)"] = pieceNode
                    }
                }
            }
        }

        private func createPieceNode(piece: Piece, at position: Position) -> SCNNode {
            let pieceNode = SCNNode()
            pieceNode.name = "piece_\(position.row)_\(position.col)"

            let material = SCNMaterial()
            if piece.color == .white {
                material.diffuse.contents = UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1.0)
                material.specular.contents = UIColor.white
                material.shininess = 0.8
            } else {
                material.diffuse.contents = UIColor(red: 0.25, green: 0.23, blue: 0.22, alpha: 1.0)
                material.specular.contents = UIColor.white
                material.shininess = 0.9
            }
            material.lightingModel = .phong

            let geometryNode = create3DPieceGeometry(type: piece.type, material: material)
            geometryNode.scale = SCNVector3(1.4, 1.4, 1.4)
            pieceNode.addChildNode(geometryNode)

            pieceNode.position = SCNVector3(
                x: Float(position.col),
                y: 0.15,
                z: Float(position.row)
            )

            pieceNode.castsShadow = true

            return pieceNode
        }

        private func create3DPieceGeometry(type: PieceType, material: SCNMaterial) -> SCNNode {
            let node = SCNNode()

            let baseHeight: Float = 0.06
            let base = SCNCylinder(radius: 0.32, height: CGFloat(baseHeight))
            base.materials = [material]
            let baseNode = SCNNode(geometry: base)
            baseNode.position = SCNVector3(0, baseHeight / 2, 0)
            node.addChildNode(baseNode)

            let base2 = SCNCylinder(radius: 0.26, height: 0.04)
            base2.materials = [material]
            let base2Node = SCNNode(geometry: base2)
            base2Node.position = SCNVector3(0, baseHeight + 0.02, 0)
            node.addChildNode(base2Node)

            let yStart: Float = baseHeight + 0.04

            switch type {
            case .pawn:
                let stemHeight: Float = 0.15
                let stem = SCNCylinder(radius: 0.12, height: CGFloat(stemHeight))
                stem.materials = [material]
                let stemNode = SCNNode(geometry: stem)
                stemNode.position = SCNVector3(0, yStart + stemHeight / 2, 0)
                node.addChildNode(stemNode)

                let collar = SCNTorus(ringRadius: 0.12, pipeRadius: 0.03)
                collar.materials = [material]
                let collarNode = SCNNode(geometry: collar)
                collarNode.position = SCNVector3(0, yStart + stemHeight, 0)
                node.addChildNode(collarNode)

                let head = SCNSphere(radius: 0.12)
                head.materials = [material]
                let headNode = SCNNode(geometry: head)
                headNode.position = SCNVector3(0, yStart + stemHeight + 0.12, 0)
                node.addChildNode(headNode)

            case .rook:
                let towerHeight: Float = 0.4
                let tower = SCNCylinder(radius: 0.18, height: CGFloat(towerHeight))
                tower.materials = [material]
                let towerNode = SCNNode(geometry: tower)
                towerNode.position = SCNVector3(0, yStart + towerHeight / 2, 0)
                node.addChildNode(towerNode)

                let platform = SCNCylinder(radius: 0.22, height: 0.05)
                platform.materials = [material]
                let platformNode = SCNNode(geometry: platform)
                platformNode.position = SCNVector3(0, yStart + towerHeight + 0.025, 0)
                node.addChildNode(platformNode)

                for i in 0..<4 {
                    let angle = Float(i) * Float.pi / 2
                    let battlement = SCNBox(
                        width: 0.08, height: 0.1, length: 0.08, chamferRadius: 0.01)
                    battlement.materials = [material]
                    let battlementNode = SCNNode(geometry: battlement)
                    battlementNode.position = SCNVector3(
                        cos(angle) * 0.15,
                        yStart + towerHeight + 0.1,
                        sin(angle) * 0.15
                    )
                    node.addChildNode(battlementNode)
                }

            case .knight:
                let neckHeight: Float = 0.3
                let neck = SCNCylinder(radius: 0.14, height: CGFloat(neckHeight))
                neck.materials = [material]
                let neckNode = SCNNode(geometry: neck)
                neckNode.position = SCNVector3(0, yStart + neckHeight / 2, 0)
                node.addChildNode(neckNode)

                let headLength: Float = 0.35
                let headBox = SCNBox(
                    width: 0.15, height: 0.22, length: CGFloat(headLength), chamferRadius: 0.04)
                headBox.materials = [material]
                let headNode = SCNNode(geometry: headBox)
                headNode.position = SCNVector3(0, yStart + neckHeight + 0.08, 0.1)
                headNode.eulerAngles.x = Float.pi * 0.2
                node.addChildNode(headNode)

                for xOff: Float in [-0.06, 0.06] {
                    let ear = SCNCone(topRadius: 0, bottomRadius: 0.03, height: 0.08)
                    ear.materials = [material]
                    let earNode = SCNNode(geometry: ear)
                    earNode.position = SCNVector3(xOff, yStart + neckHeight + 0.25, 0.05)
                    node.addChildNode(earNode)
                }

            case .bishop:
                let bodyHeight: Float = 0.45
                let body = SCNCone(topRadius: 0.08, bottomRadius: 0.18, height: CGFloat(bodyHeight))
                body.materials = [material]
                let bodyNode = SCNNode(geometry: body)
                bodyNode.position = SCNVector3(0, yStart + bodyHeight / 2, 0)
                node.addChildNode(bodyNode)

                let collar = SCNTorus(ringRadius: 0.15, pipeRadius: 0.025)
                collar.materials = [material]
                let collarNode = SCNNode(geometry: collar)
                collarNode.position = SCNVector3(0, yStart + 0.08, 0)
                node.addChildNode(collarNode)

                let mitre = SCNCone(topRadius: 0, bottomRadius: 0.08, height: 0.15)
                mitre.materials = [material]
                let mitreNode = SCNNode(geometry: mitre)
                mitreNode.position = SCNVector3(0, yStart + bodyHeight + 0.075, 0)
                node.addChildNode(mitreNode)

                let tipBall = SCNSphere(radius: 0.035)
                tipBall.materials = [material]
                let tipBallNode = SCNNode(geometry: tipBall)
                tipBallNode.position = SCNVector3(0, yStart + bodyHeight + 0.17, 0)
                node.addChildNode(tipBallNode)

            case .queen:
                let bodyHeight: Float = 0.5
                let body = SCNCone(topRadius: 0.12, bottomRadius: 0.2, height: CGFloat(bodyHeight))
                body.materials = [material]
                let bodyNode = SCNNode(geometry: body)
                bodyNode.position = SCNVector3(0, yStart + bodyHeight / 2, 0)
                node.addChildNode(bodyNode)

                let collar = SCNTorus(ringRadius: 0.16, pipeRadius: 0.03)
                collar.materials = [material]
                let collarNode = SCNNode(geometry: collar)
                collarNode.position = SCNVector3(0, yStart + 0.1, 0)
                node.addChildNode(collarNode)

                let crownRing = SCNTorus(ringRadius: 0.1, pipeRadius: 0.025)
                crownRing.materials = [material]
                let crownRingNode = SCNNode(geometry: crownRing)
                crownRingNode.position = SCNVector3(0, yStart + bodyHeight + 0.02, 0)
                node.addChildNode(crownRingNode)

                for i in 0..<5 {
                    let angle = Float(i) * Float.pi * 2 / 5
                    let point = SCNCone(topRadius: 0, bottomRadius: 0.03, height: 0.1)
                    point.materials = [material]
                    let pointNode = SCNNode(geometry: point)
                    pointNode.position = SCNVector3(
                        cos(angle) * 0.08,
                        yStart + bodyHeight + 0.08,
                        sin(angle) * 0.08
                    )
                    node.addChildNode(pointNode)
                }

                let orb = SCNSphere(radius: 0.04)
                orb.materials = [material]
                let orbNode = SCNNode(geometry: orb)
                orbNode.position = SCNVector3(0, yStart + bodyHeight + 0.14, 0)
                node.addChildNode(orbNode)

            case .king:
                let bodyHeight: Float = 0.55
                let body = SCNCone(topRadius: 0.12, bottomRadius: 0.2, height: CGFloat(bodyHeight))
                body.materials = [material]
                let bodyNode = SCNNode(geometry: body)
                bodyNode.position = SCNVector3(0, yStart + bodyHeight / 2, 0)
                node.addChildNode(bodyNode)

                let collar = SCNTorus(ringRadius: 0.16, pipeRadius: 0.03)
                collar.materials = [material]
                let collarNode = SCNNode(geometry: collar)
                collarNode.position = SCNVector3(0, yStart + 0.1, 0)
                node.addChildNode(collarNode)

                let crownBase = SCNCylinder(radius: 0.1, height: 0.06)
                crownBase.materials = [material]
                let crownBaseNode = SCNNode(geometry: crownBase)
                crownBaseNode.position = SCNVector3(0, yStart + bodyHeight + 0.03, 0)
                node.addChildNode(crownBaseNode)

                let crossV = SCNBox(width: 0.05, height: 0.2, length: 0.05, chamferRadius: 0.01)
                crossV.materials = [material]
                let crossVNode = SCNNode(geometry: crossV)
                crossVNode.position = SCNVector3(0, yStart + bodyHeight + 0.16, 0)
                node.addChildNode(crossVNode)

                let crossH = SCNBox(width: 0.14, height: 0.04, length: 0.04, chamferRadius: 0.008)
                crossH.materials = [material]
                let crossHNode = SCNNode(geometry: crossH)
                crossHNode.position = SCNVector3(0, yStart + bodyHeight + 0.22, 0)
                node.addChildNode(crossHNode)
            }

            return node
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView = gesture.view as? SCNView else { return }
            let location = gesture.location(in: scnView)

            let hitResults = scnView.hitTest(
                location,
                options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.closest.rawValue])

            if let hit = hitResults.first {
                var targetNode: SCNNode? = hit.node
                while targetNode != nil {
                    if let name = targetNode?.name,
                        name.hasPrefix("tile_") || name.hasPrefix("piece_")
                    {
                        break
                    }
                    targetNode = targetNode?.parent
                }

                guard let nodeName = targetNode?.name else { return }

                if nodeName.hasPrefix("tile_") {
                    let parts = nodeName.replacingOccurrences(of: "tile_", with: "").split(
                        separator: "_")
                    if parts.count == 2, let row = Int(parts[0]), let col = Int(parts[1]) {
                        let position = Position(row: row, col: col)
                        DispatchQueue.main.async {
                            self.viewModel.handleSquareTap(at: position)
                        }
                    }
                } else if nodeName.hasPrefix("piece_") {
                    let parts = nodeName.replacingOccurrences(of: "piece_", with: "").split(
                        separator: "_")
                    if parts.count == 2, let row = Int(parts[0]), let col = Int(parts[1]) {
                        let position = Position(row: row, col: col)
                        DispatchQueue.main.async {
                            self.viewModel.handleSquareTap(at: position)
                        }
                    }
                }
            }
        }
    }
}
