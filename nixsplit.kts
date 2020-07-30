#!/usr/bin/env -S kotlinc -script --

System.`in`.bufferedReader().lines().forEach { println(it.split("-").dropLast(1).joinToString("-")) }
