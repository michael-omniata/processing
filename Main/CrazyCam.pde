import java.awt.*; 
import java.awt.Robot;
import java.util.HashMap;
import java.awt.event.KeyEvent;
import processing.core.*; 
//import processing.event.KeyEvent;
import java.awt.Toolkit;

Toolkit t = Toolkit.getDefaultToolkit();


public class CrazyCam {   
  PMatrix3D originalMatrix; // for HUD restore

  public CrazyCam(PApplet papplet) { 
    applet = papplet; 

    originalMatrix = papplet.getMatrix((PMatrix3D)null);

    papplet.registerMethod("draw", this); 
    //papplet.registerMethod("keyEvent", this); 
    try { 
      robot = new Robot();
    } 
    catch(Exception exception) {
    } 
    speed = 3F; 
    sensitivity = 2.0F; 
    eye = new PVector(0.0F, 0.0F, 0.0F); 
    up = new PVector(0.0F, 1.0F, 0.0F); 
    right = new PVector(1.0F, 0.0F, 0.0F); 
    forward = new PVector(0.0F, 0.0F, 1.0F); 
    velocity = new PVector(0.0F, 0.0F, 0.0F); 
    pan = 0.0F; 
    tilt = 0.0F; 
    friction = 0.75F; 
    keys = new HashMap(); 
    papplet.perspective(1.047198F, (float)papplet.width / (float)papplet.height, 0.01F, 1000F);
  }   

  public void beginHUD() {
    applet.pushMatrix();
    applet.hint( DISABLE_DEPTH_TEST );
    applet.resetMatrix();
    applet.applyMatrix( originalMatrix );
  }

  public void endHUD() {
    applet.hint( ENABLE_DEPTH_TEST );
    applet.popMatrix();
  }



  public void draw() { 
    Boolean b = t.getLockingKeyState(KeyEvent.VK_CAPS_LOCK);

    if ( b ) {
      mouse = MouseInfo.getPointerInfo().getLocation(); 
      if (prevMouse == null) prevMouse = new Point(mouse.x, mouse.y); 
      int i = GraphicsEnvironment.getLocalGraphicsEnvironment().getMaximumWindowBounds().width; 
      int j = GraphicsEnvironment.getLocalGraphicsEnvironment().getMaximumWindowBounds().height; 
      if (mouse.x < 1 && mouse.x - prevMouse.x < 0) { 
        robot.mouseMove(i - 2, mouse.y); 
        mouse.x = i - 2; 
        prevMouse.x = i - 2;
      } 
      if (mouse.x > i - 2 && mouse.x - prevMouse.x > 0) { 
        robot.mouseMove(2, mouse.y); 
        mouse.x = 2; 
        prevMouse.x = 2;
      } 
      if (mouse.y < 1 && mouse.y - prevMouse.y < 0) { 
        robot.mouseMove(mouse.x, j - 2); 
        mouse.y = j - 2; 
        prevMouse.y = j - 2;
      } 
      if (mouse.y > j - 1 && mouse.y - prevMouse.y > 0) { 
        robot.mouseMove(mouse.x, 2); 
        mouse.y = 2; 
        prevMouse.y = 2;
      } 
      pan += PApplet.map(mouse.x - prevMouse.x, 0.0F, applet.width, 0.0F, 6.283185F) * sensitivity; 
      tilt += PApplet.map(mouse.y - prevMouse.y, 0.0F, applet.height, 0.0F, 3.141593F) * sensitivity; 
      tilt = clamp(tilt, -1.562981F, 1.562981F); 
      if (tilt == 1.570796F) tilt += 0.001F; 
      forward = new PVector(PApplet.cos(pan), PApplet.tan(tilt), PApplet.sin(pan)); 
      forward.normalize(); 
      right = new PVector(PApplet.cos(pan - 1.570796F), 0.0F, PApplet.sin(pan - 1.570796F)); 
      prevMouse = new Point(mouse.x, mouse.y); 

      if (keyPressed) {
        if (key == 'a') velocity.add(PVector.mult(right, speed)); 
        if (key == 'd') velocity.sub(PVector.mult(right, speed)); 
        if (key == 'w') velocity.add(PVector.mult(forward, speed)); 
        if (key == 's') velocity.sub(PVector.mult(forward, speed)); 
        if (key == 'q') velocity.add(PVector.mult(up, speed)); 
        if (key == 'e') velocity.sub(PVector.mult(up, speed)); 
      }

      velocity.mult(friction); 
      eye.add(velocity); 
      center = PVector.add(eye, forward); 
      applet.camera(eye.x, eye.y, eye.z, center.x, center.y, center.z, up.x, up.y, up.z);
    }
  }   

  /*
  public void keyEvent(KeyEvent keyevent) { 
    char c = keyevent.getKey(); 
    switch(keyevent.getAction()) { 
    case 1: // '\001' keys.put(character.valueOf(c), boolean.valueOf(true)); break;
    case 2: // '\002' keys.put(character.valueOf(c), boolean.valueOf(false)); break;
    }
  }
  */

  private float clamp(float f, float f1, float f2) { 
    if (f > f2) return f2; 
    if (f < f1) return f1; 
    else return f;
  }   

  public static final String VERSION = "1.1"; 
  public float speed; 
  public float sensitivity; 
  public float friction; 
  public PApplet applet; 
  private Robot robot; 
  public PVector eye; 
  public PVector center; 
  private PVector up; 
  private PVector right; 
  private PVector forward; 
  private PVector velocity; 
  private Point mouse; 
  private Point prevMouse; 
  private float pan; 
  private float tilt; 
  private HashMap keys;
}  
