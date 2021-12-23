local Ball = {type="ball", running=false, id=0}

function Ball:new (o)
	o = o or {}
	setmetatable( o, self)
	self.__index = self;
	return o
end

function Ball:spawn(x, y, radius, id)
	self.s = display.newCircle(x, y, radius);
	self.s.id = id
	self.s.pp = self;
end

function Ball:addBody(ballCollisionFilter, collisionListener)
	physics.addBody(self.s, 'dynamic', {density = 0, friction = 0, bounce = 1, radius = 16, filter = ballCollisionFilter});
	self.s.collision = collisionListener
	self.s:addEventListener("collision");
end

function Ball:getID()
	return id
end

function Ball:getX()
	return self.s.x
end

function Ball:getY()
	return self.s.y
end

function Ball:setX(x)
	self.s.x = x
end

function Ball:setY(y)
	self.s.y = y
end

function Ball:getShape()
	return self.s
end

function Ball:setRunning(bool)
	self.running = bool
end

function Ball:getRunning()
	return self.running
end

function Ball:transitionTo(time, x, y)
	transition.to(self.s, {time = TRANSITION_TIME, x = x, y = y}); --moves all balls to the original starting position
end

function Ball:delete()
	self.s:removeSelf( )
end

return Ball