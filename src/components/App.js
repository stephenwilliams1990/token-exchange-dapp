import React, { Component } from 'react'
import './App.css'
import Navbar from './Navbar'
import Content from './Content'
import { connect } from 'react-redux'
import { 
  loadWeb3, 
  loadAccount, 
  loadToken, 
  loadExchange 
} from '../store/interactions' 
import { contractsLoadedSelector } from '../store/selectors'
 
class App extends Component { // Component from react will come with lots of functionalities for free 
  componentDidMount() { // magic function that comes with react *** changed from componentWillMount()
    this.loadBlockchainData(this.props.dispatch)
  }

  async loadBlockchainData(dispatch) {
    const web3 = await loadWeb3(dispatch)
    await web3.eth.net.getNetworkType()
    const networkId = await web3.eth.net.getId()
    await loadAccount(web3, dispatch)
    const token = await loadToken(web3, networkId, dispatch)
    if(!token) {
      window.alert('Token smart contract not detected on the current network. Please select another network with Metamask.')
      return
    }
    const exchange = await loadExchange(web3, networkId, dispatch)
    if(!exchange) {
      window.alert('Exchange smart contract not detected on the current network. Please select another network with Metamask.')
      return
    }
    // const totalSupply = await token.methods.totalSupply().call()
   
  }

  render() {
    return (
      <div>
        <Navbar />
        { this.props.contractsLoaded ? <Content /> : <div className="content"></div> } 
      </div>
    );
  }
}

function mapStateToProps(state) {
  return {
    contractsLoaded: contractsLoadedSelector(state)
  }
}

export default connect(mapStateToProps)(App); // this connect function connects our app to redux to get the information inside of props
