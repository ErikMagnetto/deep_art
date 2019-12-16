import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Artist {
  String name;
  String demo;
  bool isChoose;

  Artist(this.name, this.demo, this.isChoose);
}