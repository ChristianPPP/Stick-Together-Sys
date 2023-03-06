import {
  CollectionReference,
  DocumentData,
  addDoc,
  collection,
  deleteDoc,
  doc,
  updateDoc,
} from '@firebase/firestore';
import { getFirestore } from "firebase/firestore";
import { initializeApp } from "firebase/app";
import { Firestore, collectionData, docData, query, where } from '@angular/fire/firestore';
import { getAuth } from "@angular/fire/auth";

import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private usersCollection: CollectionReference<DocumentData>;
  firebaseConfig = {
    apiKey: "AIzaSyBpp-VKyA8GhBK-EVgwJJb63_6rlqad3Xk",
    authDomain: "flutter-geoloca.firebaseapp.com",
    projectId: "flutter-geoloca",
    storageBucket: "flutter-geoloca.appspot.com",
    messagingSenderId: "667166684456",
    appId: "1:667166684456:web:a4656ef841c166d37c8c1d"
  };

  app = initializeApp(this.firebaseConfig);
  db = getFirestore(this.app);

  constructor(private authService: AuthService) {
    this.usersCollection = collection(this.db, 'usuarios');
  }

  getAll(equipo: string) {
    const q = query(collection(this.db, "usuarios"), where("equipo", "==", equipo));
    return collectionData(q, {
      idField: 'id',
    }) as Observable<any[]>;
  }

  delete(id: string) {
    const userDocumentReference = doc(this.db, `usuarios/${id}`);
    return deleteDoc(userDocumentReference);
  }
}
