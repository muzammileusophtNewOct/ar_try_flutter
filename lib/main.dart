import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:async';
import 'dart:math' as math;


//-- Example 2 of tom rotating in circular motion
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, 
    home: UniqueMovingTom()
  ));
}

class UniqueMovingTom extends StatefulWidget {
  const UniqueMovingTom({super.key});

  @override
  State<UniqueMovingTom> createState() => _UniqueMovingTomState();
}

class _UniqueMovingTomState extends State<UniqueMovingTom> {
  ArCoreController? arCoreController;
  ArCoreNode? tomNode;
  
  // Animation variables
  Timer? timer;
  double angle = 0.0;
  vector.Vector3 centerPosition = vector.Vector3(0, 0, -1.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Patrol Tom'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true, // Floor tap enable karne ke liye
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    
    // Jab user floor par tap kare toh Tom wahan move ho jaye
    arCoreController?.onPlaneTap = _handleOnPlaneTap;
    
    // Initial Tom add karein
    _spawnTom(centerPosition);
    _startUniqueAnimation();
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    // Tap wali jagah ko naya center bana dein
    centerPosition = hit.pose.translation;
    _spawnTom(centerPosition);
  }

  void _spawnTom(vector.Vector3 position) {
    // Agar pehle se node hai toh remove karein
    if (tomNode != null) {
      arCoreController?.removeNode(nodeName: "tom_patrol");
    }

    tomNode = ArCoreReferenceNode(
      name: "tom_patrol",
      object3DFileName: "tom.glb", // Make sure file is in android/assets
      position: position,
      scale: vector.Vector3(0.5, 0.5, 0.5),
    );

    arCoreController?.addArCoreNode(tomNode!);
  }

  // Unique Circular Animation Logic
  void _startUniqueAnimation() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (tomNode == null || arCoreController == null) return;

      angle += 0.05; // Speed of rotation
      double radius = 0.6; // Kitni door tak ghoomega

      // Calculate new X and Z for circular movement
      double newX = centerPosition.x + radius * math.cos(angle);
      double newZ = centerPosition.z + radius * math.sin(angle);
      
      vector.Vector3 newPos = vector.Vector3(newX, centerPosition.y, newZ);

      // Unique Feature: Moving with Rotation 
      // Tom ka face movement ki taraf karne ke liye y-axis rotation
      double rotationY = -angle + (math.pi / 2);

      // Update Node (Re-adding for smooth position in this specific plugin)
      _updateNodePosition(newPos, rotationY);
    });
  }

  void _updateNodePosition(vector.Vector3 pos, double rotationY) {
    arCoreController?.removeNode(nodeName: "tom_patrol");
    
    tomNode = ArCoreReferenceNode(
      name: "tom_patrol",
      object3DFileName: "tom.glb",
      position: pos,
      // Quaternion use hota hai rotation ke liye
      rotation: vector.Vector4(0, 1, 0, rotationY), 
      scale: vector.Vector3(0.5, 0.5, 0.5),
    );

    arCoreController?.addArCoreNode(tomNode!);
  }

  @override
  void dispose() {
    timer?.cancel();
    arCoreController?.dispose();
    super.dispose();
  }
}







// //-- Example 1 of tom jerry showing through glb model type

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp( MovingTom());
// }



// class MovingTom extends StatefulWidget {
//   const MovingTom({super.key});

//   @override
//   State<MovingTom> createState() => _MovingTomState();
// }

// class _MovingTomState extends State<MovingTom> {
//   late ArCoreController arCoreController;
//   ArCoreNode? carNode;
//   double tomZ = -1.5;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(title: const Text('AR Moving Tom')),
//         body: ArCoreView(
//           onArCoreViewCreated: _onArCoreViewCreated,
//         ),
//       ),
//     );
//   }

//   void _onArCoreViewCreated(ArCoreController controller) {
//     arCoreController = controller;

//     _addTom(tomZ);

//     _startTomAnimation();
//   }


// void _addTom(double zPosition) async {
//   // Remove previous node if exists
//   if (carNode != null) {
//     arCoreController.removeNode(nodeName: "car");
//   }

//   carNode = ArCoreReferenceNode(
//     // Just the filename as it appears in android/app/src/main/assets
//     object3DFileName: "tom.glb", 
//     name: "car",
//     position: vector.Vector3(0, 0, zPosition),
//     scale: vector.Vector3(0.3, 0.3, 0.3),
//   );

//   arCoreController.addArCoreNode(carNode!);
// }


//   void _startTomAnimation() {
//     const duration = Duration(milliseconds: 50);
//     Timer.periodic(duration, (timer) {
//       tomZ -= 0.02;

//       if (tomZ < -3.0) tomZ = -1.5;

//       // Re-add node at new position
//       _addTom(tomZ);
//     });
//   }

//   @override
//   void dispose() {
//     arCoreController.dispose();
//     super.dispose();
//   }
// }

