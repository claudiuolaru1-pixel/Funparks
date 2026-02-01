import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/park.dart';

final _db = FirebaseFirestore.instance;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Park>> fetchParks() async {
    final snap = await _db.collection('parks').get();
    return snap.docs.map((d) => Park.fromJson(d.data())).toList();
  }

  Future<List<Map<String, dynamic>>> fetchAttractions(String parkId) async {
    final snap = await _db.collection('parks').doc(parkId).collection('attractions').get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchFood(String parkId) async {
    final snap = await _db.collection('parks').doc(parkId).collection('food').get();
    return snap.docs.map((d) => d.data()).toList();
  }
}


  Future<Map<String, dynamic>> fetchMap(String parkId) async {
    final parkDoc = await _db.collection('parks').doc(parkId).get();
    final mapDoc = await _db.collection('parks').doc(parkId).collection('map').doc('pins').get();
    return {
      'svg_url': parkDoc.data()?['map_svg_url'],
      'width': mapDoc.exists ? (mapDoc.data()?['width'] ?? 800) : 800,
      'height': mapDoc.exists ? (mapDoc.data()?['height'] ?? 600) : 600,
      'pins': mapDoc.exists ? (mapDoc.data()?['pins'] ?? []) : []
    };
  }


