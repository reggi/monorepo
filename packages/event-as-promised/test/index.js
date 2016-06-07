import Promise from 'bluebird'
import assert from 'assert'
import EventAsPromised from '../src/index.js'

describe('EventAsPromised', () => {
  it('should work with one on handler', async () => {
    let event = new EventAsPromised()

    let run = [false]

    event.on('customerAdd', (data) => {
      run[0] = true
      assert.deepEqual(data, {'name': 'Thomas'})
      let status = {'added': true}
      return Promise.resolve(status).delay(10)
    })

    assert.equal(run[0], false)

    let data = await event.emit('customerAdd', {'name': 'Thomas'})

    assert.deepEqual(data, [{'added': true}])

    assert.equal(run[0], true)

  })
  it('should work with two on handlers', async () => {
    let event = new EventAsPromised()

    let run = [false, false]

    event.on('customerAdd', (data) => {
      run[0] = true
      assert.deepEqual(data, {'name': 'Thomas'})
      let status = {'added': true}
      return Promise.resolve(status).delay(10)
    })

    assert.deepEqual(run, [false, false])

    event.on('customerAdd', (data) => {
      run[1] = true
      assert.deepEqual(data, {'name': 'Thomas'})
      let status = {'added': false}
      return Promise.resolve(status).delay(10)
    })

    assert.deepEqual(run, [false, false])

    let data = await event.emit('customerAdd', {'name': 'Thomas'})

    assert.deepEqual(data, [{'added': true}, {'added': false}])

    assert.deepEqual(run, [true, true])

  })
})
