https://www.linkedin.com/posts/boga-vivek-703272251_vlsi-asic-rtldesign-ugcPost-7430485469915828224--8T9?utm_source=share&utm_medium=member_desktop&rcm=ACoAAD4nMHMB2vvp5H1lBlx__2iKjFK5zzrefxo

🚀 SPI Master with FIFO (ASIC Implementation)
📌 Overview

This project presents the design and ASIC implementation of a configurable SPI Master IP with integrated FIFO, developed as part of the VLSI Make-A-Thon 2026 conducted by the Centre for Nanoelectronics and VLSI Design (CNVD), VIT Chennai.

🏆 Achievement: 3rd Prize in VLSI Make-A-Thon 2026
📍 Domain: Digital IC Design / ASIC Implementation

🔧 Features
CPOL/CPHA programmable (supports all 4 SPI modes)
Configurable 8-bit / 16-bit data transfer
Integrated 16-depth FIFO buffer
Interrupt generation mechanism
Baud-rate clock divider derived from 200 MHz system clock
Designed for high-frequency operation (200 MHz target)
🏗️ Design Flow (RTL → GDSII)

The project was implemented through a complete ASIC design flow:

RTL Design
Verilog HDL implementation of SPI Master and FIFO
Functional Verification
Structured testbench for protocol validation
Verified SPI communication across all modes
Synthesis
Logic synthesis using Cadence Genus
Physical Design
Floorplanning
Power planning (rings & stripes)
Placement
Clock Tree Synthesis (CTS)
Clock network optimization for minimal skew
Routing & Optimization
Post-CTS timing optimization
Signal integrity considerations
📊 Results
✅ Timing Closure Achieved at 200 MHz
✅ Successful RTL-to-GDSII implementation
✅ Functionally verified across SPI modes
🧠 Key Learnings
Backend-aware RTL design practices
Timing closure techniques for high-frequency designs
Trade-offs in PPA (Power, Performance, Area)
Real-world ASIC implementation constraints
