import { useState, useEffect } from "react";
import { ethers } from "ethers";
import Web3 from "web3";

import {
    Grid,
    Container,
    Typography,
    TextField,
    FormControl,
    OutlinedInput,
    InputAdornment,
    Button
} from "@mui/material";
import { gameContractABI } from "../abi/GameContract";

export const GamePage = () => {
    const [gameContract, setGameContract] = useState("");
    const [bet, setBet] = useState(0); 
    const [wallet, setWallet] = useState({});
    const [winner, setWinner] = useState("");

    if (window.ethereum) {
		console.log("Connected");
	} else {
		alert("install metamask extension!!");
	}

    const web3 = new Web3(Web3.givenProvider);

	const onSubmit = () => {
		const myContract = new web3.eth.Contract(gameContractABI, gameContract);
		var weiValue = web3.utils.toWei(bet.toString(), "wei");

        console.log('wallet', wallet, "weiValue", weiValue)

		myContract.methods.makeADecision()
			.send({ from: wallet.address, gas: 380000, value: weiValue }, function (err, res) {
				console.log(err, res);
			});
	};

    const getWinner = () => {
        const myContract = new web3.eth.Contract(gameContractABI, gameContract);
        myContract.methods.getWinner()
            .send({ from: wallet.address, gas: 380000, value: 0 }, function (err, res) {
                console.log(err, res);
                if (!err) {
                    myContract.events
                        .winnerChoosed()
                        .on("data", (event) => {
                            setWinner(event.returnValues._winner);
                        })
                        .on("error", console.error);
                } else {
                    alert("Видимо игра еще не закончилась.");
                }
            });
    }

    useEffect(() => {
		window.ethereum.request({ method: "eth_requestAccounts" })
			.then((res) => {
                window.ethereum.request({
                    method: "eth_getBalance",
                    params: [res[0], "latest"],
                }).then((balance) => 
                    setWallet({
                        address: res[0],
                        balance: ethers.utils.formatEther(balance)
                    })
                );
            });
	}, []);

    return (
        <div>
            <Grid container spacing={2}>
                <Grid item xs={12}>
                    <Typography variant="h4" textAlign="center" marginY={2}>
                        Сделать ставку
                    </Typography>
                </Grid>
                <Grid item xs={3} />
                <Grid item xs={6} style={{ display: "flex", justifyContent: 'center' }}>
                    <TextField
                        fullWidth
                        label="адрес контракта игры"
                        variant="outlined"
                        value={gameContract}
                        onChange={(e) => setGameContract(e.target.value)}
                    />
                </Grid>
                <Grid item xs={3} />
                <Grid item xs={3} />
                <Grid item xs={3} style={{ display: "flex", justifyContent: 'center' }}>
                    <FormControl sx={{ m: 1 }} variant="outlined" fullWidth>
                        <OutlinedInput
                            id="outlined-adornment-bet"
                            endAdornment={<InputAdornment position="end">wei</InputAdornment>}
                            aria-describedby="outlined-bet-helper-text"
                            inputProps={{'aria-label': 'bet'}}
                            value={bet}
                            onChange={(e) => setBet(e.target.value)}
                        />
                    </FormControl>
                </Grid>
                <Grid item xs={3} style={{ display: "flex", justifyContent: 'center' }}>
                    <Button variant="contained" color="success" onClick={onSubmit} fullWidth sx={{ m: 1 }}>
                        Отправить
                    </Button>
                </Grid>

                <Grid item xs={12} />
                <Grid item sx={6}/>
                <Grid item xs={3} >
                    <Button variant="contained" color="success" onClick={getWinner} sx={{ m: 1 }}>
                        Определеить победителя
                    </Button>
                </Grid>
                <Grid item xs={3}>
                    {winner ? `Победил ${winner}` : ""}
                </Grid>
            </Grid>
        </div>
    );
};