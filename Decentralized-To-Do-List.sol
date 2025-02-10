// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TodoList {
    struct Task {
        uint id;
        string content;
        bool completed;
    }

    mapping(address => Task[]) private userTasks;
    event TaskCreated(address indexed user, uint id, string content);
    event TaskCompleted(address indexed user, uint id, bool completed);

    function createTask(string memory _content) external {
        uint taskId = userTasks[msg.sender].length;
        userTasks[msg.sender].push(Task(taskId, _content, false));
        emit TaskCreated(msg.sender, taskId, _content);
    }

    function getTasks() external view returns (Task[] memory) {
        return userTasks[msg.sender];
    }

    function toggleTask(uint _id) external {
        require(_id < userTasks[msg.sender].length, "Invalid task ID");
        userTasks[msg.sender][_id].completed = !userTasks[msg.sender][_id].completed;
        emit TaskCompleted(msg.sender, _id, userTasks[msg.sender][_id].completed);
    }
}

// Frontend (React + TypeScript)
import { useEffect, useState } from "react";
import { ethers } from "ethers";
import todoListAbi from "./TodoList.json";

const CONTRACT_ADDRESS = "YOUR_CONTRACT_ADDRESS_HERE";

const App = () => {
    const [tasks, setTasks] = useState([]);
    const [newTask, setNewTask] = useState("");
    const [provider, setProvider] = useState(null);
    const [signer, setSigner] = useState(null);
    const [contract, setContract] = useState(null);

    useEffect(() => {
        const loadBlockchainData = async () => {
            if (window.ethereum) {
                const _provider = new ethers.providers.Web3Provider(window.ethereum);
                const _signer = _provider.getSigner();
                const _contract = new ethers.Contract(CONTRACT_ADDRESS, todoListAbi, _signer);
                setProvider(_provider);
                setSigner(_signer);
                setContract(_contract);
                fetchTasks(_contract);
            }
        };
        loadBlockchainData();
    }, []);

    const fetchTasks = async (_contract) => {
        const tasks = await _contract.getTasks();
        setTasks(tasks);
    };

    const createTask = async () => {
        if (!newTask) return;
        const tx = await contract.createTask(newTask);
        await tx.wait();
        setNewTask("");
        fetchTasks(contract);
    };

    const toggleTask = async (id) => {
        const tx = await contract.toggleTask(id);
        await tx.wait();
        fetchTasks(contract);
    };

    return (
        <div className="p-5">
            <h1 className="text-2xl font-bold">Decentralized To-Do List</h1>
            <input 
                type="text" 
                value={newTask} 
                onChange={(e) => setNewTask(e.target.value)}
                className="border p-2 my-2 w-full"
                placeholder="New task..."
            />
            <button onClick={createTask} className="bg-blue-500 text-white p-2 rounded">Add Task</button>
            <ul className="mt-4">
                {tasks.map((task, index) => (
                    <li key={index} className="p-2 border flex justify-between">
                        <span className={task.completed ? "line-through" : ""}>{task.content}</span>
                        <button onClick={() => toggleTask(task.id)} className="text-blue-500">Toggle</button>
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default App;
