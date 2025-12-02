# KUKA Robot Language (KRL) Grammar

## Overview

Complete BNFC grammar for KUKA Robot Language (KRL) based on KRL-Syntax 8.x.

**Status**: ✅ 137 rules validated

## Language Features

### Core Structure

- **SRC Files**: Program files with DEF/END blocks
- **DAT Files**: Data files with DEFDAT/ENDDAT blocks
- Access control: `&ACCESS RVP` (Read/Visible/Protected)

### Data Types

| Type        | Description        | Example                   |
| ----------- | ------------------ | ------------------------- |
| `INT`       | Integer            | `counter = 10`            |
| `REAL`      | Floating point     | `velocity = 100.5`        |
| `BOOL`      | Boolean            | `running = TRUE`          |
| `CHAR`      | Character          | `ch = "A"`                |
| `ENUM`      | Enumeration        | Custom enums              |
| `STRUC`     | Structure          | User-defined              |
| `AXIS`      | Joint coordinates  | `{A1 0.0, A2 -90.0, ...}` |
| `E6AXIS`    | 6-axis + external  | `{A1..A6, E1, E2}`        |
| `E6POS`     | Cartesian position | `{X Y Z A B C S T}`       |
| `POS`       | Position           | Cartesian coordinates     |
| `FRAME`     | Coordinate frame   | Transformation            |
| `LOAD_DATA` | Load parameters    | Mass, center of mass      |
| `TOOL_DATA` | Tool parameters    | TCP offset                |
| `BASE_DATA` | Base parameters    | Base frame                |

### Arrays

```krl
DECL INT values[10]              ; 1D array
DECL REAL matrix[3,3]            ; 2D array
DECL E6POS waypoints[100]        ; Position array
```

### Motion Commands

| Command   | Description     | Example                        |
| --------- | --------------- | ------------------------------ |
| `PTP`     | Point-to-point  | `PTP {A1 0, A2 -90, ...}`      |
| `PTP_REL` | Relative PTP    | `PTP_REL {A1 10, ...}`         |
| `LIN`     | Linear motion   | `LIN {X 500, Y 0, Z 600, ...}` |
| `LIN_REL` | Relative linear | `LIN_REL {X 10, Y 0, Z 0}`     |
| `CIRC`    | Circular motion | `CIRC auxPoint, targetPoint`   |
| `SLIN`    | Spline motion   | `SLIN targetPoint`             |

### Motion Modifiers

- `C_DIS`: Continuous distance
- `C_ORI`: Continuous orientation
- `C_VEL`: Continuous velocity
- `C_PTP`: Continuous PTP

### Control Structures

#### IF-THEN-ELSE

```krl
IF condition THEN
  statements
ELSE
  statements
ENDIF
```

#### SWITCH-CASE

```krl
SWITCH expression
  CASE value1
    statements
  CASE value2
    statements
  DEFAULT
    statements
ENDSWITCH
```

#### FOR Loop

```krl
FOR counter = 1 TO 10 STEP 2
  statements
ENDFOR
```

#### WHILE Loop

```krl
WHILE condition
  statements
ENDWHILE
```

#### REPEAT-UNTIL

```krl
REPEAT
  statements
UNTIL condition
```

#### LOOP

```krl
LOOP
  statements
  IF condition THEN
    EXIT
  ENDIF
ENDLOOP
```

### I/O Operations

```krl
; Digital I/O
$OUT[1] = TRUE
input_value = $IN[1]

; Pulse output
PULSE ($OUT[1], TRUE, 0.5)

; Wait for condition
WAIT FOR $IN[1] == TRUE
WAIT SEC 2.0
```

### System Variables

- `$POS_ACT`: Actual position
- `$AXIS_ACT`: Actual axis angles
- `$BASE`: Base coordinate system
- `$TOOL`: Tool coordinate system
- `$VEL`: Velocity override
- `$ACC`: Acceleration override
- `$IN[n]`: Digital input
- `$OUT[n]`: Digital output
- `$ANIN[n]`: Analog input
- `$ANOUT[n]`: Analog output

### Interrupt Handling

```krl
; Declare interrupt
INTERRUPT DECL 1 WHEN $IN[10] == TRUE DO handler()

; Enable/disable
INTERRUPT ON 1
INTERRUPT OFF 1
```

### Operators

#### Arithmetic

- `+` Addition
- `-` Subtraction
- `*` Multiplication
- `/` Division

#### Comparison

- `==` Equal
- `<>` Not equal
- `<` Less than
- `<=` Less or equal
- `>` Greater than
- `>=` Greater or equal

#### Logical

- `AND` Logical AND
- `OR` Logical OR
- `EXOR` Exclusive OR
- `NOT` Logical NOT

### Functions and Procedures

```krl
DEF function_name(param1:INT, OUT param2:REAL)
  ; Local declarations
  DECL INT local_var

  ; Statements
  local_var = param1 * 2
  param2 = local_var

  ; Optional return
  RETURN
END
```

## Example Programs

### Simple Motion

```krl
&ACCESS RVP
DEF simple_motion()
  DECL E6POS target

  ; Initialize
  $BASE = $NULLFRAME
  $TOOL = TOOL_DATA[1]

  ; Define position
  target = {X 500.0, Y 0.0, Z 600.0, A 0.0, B 0.0, C 0.0, S 2, T 10}

  ; Move
  PTP target
  LIN target

END
```

### I/O Control

```krl
&ACCESS RVP
DEF io_control()
  ; Read input
  IF $IN[1] == TRUE THEN
    $OUT[1] = TRUE
    WAIT SEC 1.0
    $OUT[1] = FALSE
  ENDIF
END
```

### Loop Example

```krl
&ACCESS RVP
DEF loop_example()
  DECL INT i

  FOR i = 1 TO 10 STEP 1
    $OUT[i] = TRUE
    WAIT SEC 0.5
    $OUT[i] = FALSE
  ENDFOR
END
```

## Build Instructions

```bash
# Generate parser
cd krl
bnfc -m --haskell -o build/ krl.cf

# Build
cd build && make

# Test
./TestKRL ../test/simple.src
```

## Test Files

- `test/simple.src` - Basic syntax test
- `test/motion.src` - Motion commands
- `test/control.src` - Control structures
- `test/data.dat` - Data declarations
- `test/io.src` - I/O operations
- `test/interrupt.src` - Interrupt handling

## Validation

```bash
$ bnfc --check krl.cf
137 rules accepted
```

## Grammar Statistics

- **Total Rules**: 137
- **Data Types**: 18
- **Motion Commands**: 6
- **Control Structures**: 7
- **Operators**: 20+
- **System Variables**: Extensive

## Next Steps

1. ✅ Grammar complete (137 rules)
2. 🚧 Generate parser with BNFC
3. 🚧 Test with example programs
4. 🚧 Implement semantic analysis
5. 🚧 LLVM code generation
6. 🚧 Runtime library for robot I/O

## Resources

- **KUKA Documentation**: KRL-Syntax 8.x
- **BNFC Manual**: http://bnfc.digitalgrammars.com/
- **KRL Reference**: KUKA System Software

---

**Status**: Grammar complete and validated ✅
