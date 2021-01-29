function [particle,operation] = InitParticle(operation, particle)
    operation.Rotation.AngularVelocity = operation.Rotation.Speed/2/pi/60;
    particle.Velocity = [0,0,operation.Rotation.AngularVelocity*operation.Rotation.Radium];