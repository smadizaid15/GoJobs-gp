# 📍 GRADUATION PROJECT 1

A cross-platform mobile application for job finding regulated to the jordanian job market.

![CI/CD Status](https://github.com/smadizaid15/gp1_mvp/actions/workflows/main.yml/badge.svg)

## 📂 Project Documentation
Beyond the code, detailed documentation regarding the project research and specifications can be found in the `docs` folder:
* [📄 View Project Documents](./docs)

## 🚀 About the Project
This project includes all the requirements specified for the gp1 ( diagrams , documentation , resources ) , include  the **MVP (Minimum Viable Product)** for our Graduation Project which demonstrates the core UI architecture and the automated deployment pipeline.

**Tech Stack:**
* **Framework:** Flutter (Dart)
* **Design:** Figma
* **Containerization:** Docker & Nginx
* **CI/CD:** GitHub Actions -> Docker Hub

## 🛠 How to Run (The "Magic" Command)
You do not need to install Flutter to run this app , The latest version is automatically containerized and hosted on Docker Hub

**Prerequisites:** Docker Desktop installed

Run this single command in your terminal:
``` using bash
docker run -p 8080:80 zaidsmadii/gp1-app:latest
then open up http://localhost:8080
