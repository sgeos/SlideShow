----------------------------------------------------------------
--
--  SlideShow.lua
--  Reads splash screen list from database and crossfades
--  between splash screens.
--
--  Written in 2012 by Brendan A R Sechter <bsechter@sennue.com>
--
--  To the extent possible under law, the author(s) have
--  dedicated all copyright and related and neighboring rights
--  to this software to the public domain worldwide. This
--  software is distributed without any warranty.
--
--  You should have received a copy of the CC0 Public Domain
--  Dedication along with this software. If not, see
--  <http://creativecommons.org/publicdomain/zero/1.0/>.
--
----------------------------------------------------------------

module ( ..., package.seeall )
require "ProgramState"
require "Database"
require "Input"
require "Log"
require "FullScreenImage"

-- State Variables
local mDone
local mSkip
local mState
local mIndex
local mSlides
local mCurrentImage
local mNextImage
local mFadeTimer
local mFadeTimerMax

-- Splash Screen List
function getSlideList ( pState )
  local db    = pState.systemDb
  local query = [[
    SELECT * FROM slide_show WHERE ?=resolution ORDER BY priority ASC
  ]]
  local stmt       = db:prepare ( query )
  local resolution = pState.textureResolution
  local params     = { resolution }
  local result     = db:bindRows ( stmt, params )
  Log.print ( #result .. " slides" )
  return result
end

-- Load Image
function loadImage ( pIndex )
  local result
  if mSlides [ pIndex ] then
    result = FullScreenImage.load ( mSlides [ pIndex ] .image )
    Log.print ( "Slide " .. pIndex .. " : " .. mSlides [ pIndex ] .image )
  else
    result = nil
  end
  return result
end

-- Flush Alpha
function flushAlpha ( )
  if mCurrentImage then
    mCurrentImage.prop:setColor ( 1, 1, 1, 1 )
  end
  if mNextImage then
    local alpha = 1 - ( mFadeTimer / mFadeTimerMax )
    mNextImage.prop:setColor ( 1, 1, 1, alpha )
  end
end

-- Update Image
function updateImage ( pIndex )
  -- Refresh Image
  if mCurrentImage then
    mCurrentImage:unload ( )
  end
  mCurrentImage = mNextImage
  mNextImage = loadImage ( pIndex )

  -- Fade Timer
  if mSkip then
    mFadeTimer = 0
  else
    mFadeTimer = mFadeTimerMax
  end
  flushAlpha ( )
end

-- On Touch
function onTouch ( pX, pY )
  if 0 == mFadeTimer then
    if pX < mState.horizontalResolution / 2 then
      mIndex = mIndex - 1
    else
      mIndex = mIndex + 1
    end
    if #mSlides < mIndex then
      mIndex = 1
    elseif mIndex < 1 then
      mIndex = #mSlides
    end
    updateImage ( mIndex )
  end
end

-- Initialize
function init ( )
  mDone         = false
  mSkip         = false
  mState        = ProgramState.getState ( )
  mIndex        = 1
  mSlides       = getSlideList ( mState )
  mCurrentImage = false
  mNextImage    = false
  mFadeTimer    = 0
  mFadeTimerMax = math.floor ( mState.fps * 1 )
  updateImage ( mIndex )
end

-- Cleanup
function cleanup ( )
  if mCurrentImage then
    mCurrentImage:unload ( )
  end
  if mNextImage then
    mNextImage:unload ( )
  end
end

-- Update
function update ( )
  local down, x, y = Input.poll ( )
  if down then
    onTouch ( x, y )
  end

  if 0 < mFadeTimer then
    mFadeTimer  = mFadeTimer - 1
    flushAlpha ( )
  end
end

-- Main Loop
function loop ( pProgramState )
  init ( )
  while not mDone do
    update ()
    coroutine.yield ( )
  end
  cleanup ( )
end

